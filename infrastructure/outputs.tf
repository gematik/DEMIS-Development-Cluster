output "kms_encryption_key_used" {
  description = "The flag to indicate if the KMS encryption key is used"
  value       = local.kms_encryption_key
}
