# Creates the own Loki bucket once and (re)applies its configuration, run by the bucket Job (/bin/sh -c).
# Environment (set by bucket.tf):
#   S3_ENDPOINT  endpoint URL of the object storage
#   BUCKET       bucket of Loki (chunks, ruler, compactor)
#   LOCK_DAYS    default object lock in days, 0 disables object lock
#   LOCK_MODE    object lock mode, COMPLIANCE or GOVERNANCE
#   SSE_TYPE     server-side encryption: none, SSE-S3 or SSE-KMS
#   KMS_KEY_ID   KMS key for SSE-KMS
#   AWS_SHARED_CREDENTIALS_FILE  credentials of the Loki identity (mounted Secret)

# Stop on the first failing command and on unset variables
set -eu

# All calls go to the configured endpoint (no AWS default endpoint)
s3() { aws --endpoint-url "$S3_ENDPOINT" s3api "$@"; }

# Bucket: create it once. Object lock can only be enabled when the bucket is created (it also
# enables versioning); on an existing bucket without lock the lock configuration below fails.
if s3 head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "Bucket $BUCKET exists"
elif [ "$LOCK_DAYS" -gt 0 ]; then
  s3 create-bucket --bucket "$BUCKET" --object-lock-enabled-for-bucket
else
  s3 create-bucket --bucket "$BUCKET"
fi

# Object lock: every new object version is locked for LOCK_DAYS days (cannot be overwritten or deleted)
if [ "$LOCK_DAYS" -gt 0 ]; then
  s3 put-object-lock-configuration --bucket "$BUCKET" --object-lock-configuration \
    "{\"ObjectLockEnabled\":\"Enabled\",\"Rule\":{\"DefaultRetention\":{\"Mode\":\"$LOCK_MODE\",\"Days\":$LOCK_DAYS}}}"
  # Deletes by Loki only add delete markers; lifecycle never removes a locked version, so the
  # noncurrent versions go one day after Loki deleted them, but never before their lock expired.
  # The delete markers left without any version are removed as well.
  s3 put-bucket-lifecycle-configuration --bucket "$BUCKET" --lifecycle-configuration \
    '{"Rules":[{"ID":"expire-noncurrent-versions","Status":"Enabled","Filter":{"Prefix":""},"NoncurrentVersionExpiration":{"NoncurrentDays":1}},{"ID":"remove-expired-delete-markers","Status":"Enabled","Filter":{"Prefix":""},"Expiration":{"ExpiredObjectDeleteMarker":true}}]}'
  # Verify: the Job fails if the storage did not apply the lock (mode and days)
  [ "$(s3 get-object-lock-configuration --bucket "$BUCKET" --query 'ObjectLockConfiguration.Rule.DefaultRetention.[Mode,Days]' --output text)" = "$(printf '%s\t%s' "$LOCK_MODE" "$LOCK_DAYS")" ]
fi

# Encryption: algorithm and default rule of the selected SSE type, empty for none
case "$SSE_TYPE" in
  SSE-S3) ALGORITHM=AES256; RULE='{"SSEAlgorithm":"AES256"}' ;;
  SSE-KMS) ALGORITHM=aws:kms; RULE="{\"SSEAlgorithm\":\"aws:kms\",\"KMSMasterKeyID\":\"$KMS_KEY_ID\"}" ;;
  *) ALGORITHM="" ;;
esac
if [ -n "$ALGORITHM" ]; then
  # Default encryption of all new objects
  s3 put-bucket-encryption --bucket "$BUCKET" --server-side-encryption-configuration \
    "{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":$RULE}]}"
  # Verify: the Job fails if the storage did not apply the algorithm
  [ "$(s3 get-bucket-encryption --bucket "$BUCKET" --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text)" = "$ALGORITHM" ]
elif s3 get-bucket-encryption --bucket "$BUCKET" >/dev/null 2>&1; then
  # Switched off: new objects are stored unencrypted, existing ones stay encrypted
  s3 delete-bucket-encryption --bucket "$BUCKET"
fi

echo "Bucket $BUCKET configured (object lock: $LOCK_MODE $LOCK_DAYS days, SSE: $SSE_TYPE)"
