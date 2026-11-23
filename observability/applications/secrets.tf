#####################
# Secrets of the namespace (as in the demis namespace, created only with their component)
#####################

locals {
  postgresql_tls_certificates_data = {
    "server.key" : base64decode(var.postgres_server_key)
    "server.crt" : base64decode(var.postgres_server_certificate)
    "ca.crt" : base64decode(var.postgres_root_ca_certificate)
  }

  # PGBouncer Specific Secrets
  userlist_content = join("\n", [for cred in var.database_credentials : "\"${cred.username}\" \"${cred.password}\""])

  object_storage_service_secret_name = "object-storage-service-secret"
  # SSE-S3 only with a passphrase (whether one is set is no secret)
  object_storage_service_sse_enabled = nonsensitive(var.object_storage_service_sse_passphrase != "")
  # Admin identity, the Loki identity restricted to its bucket and the SSE-S3 passphrase
  object_storage_service_credentials_data = merge({
    S3_ACCESS_KEY      = var.object_storage_service_access_key
    S3_SECRET_KEY      = var.object_storage_service_secret_key
    LOKI_S3_ACCESS_KEY = var.loki_s3_access_key_id
    LOKI_S3_SECRET_KEY = var.loki_s3_secret_access_key
    }, local.object_storage_service_sse_enabled ? {
    S3_SSE_PASSPHRASE = var.object_storage_service_sse_passphrase
  } : {})

  # AWS shared credentials file of the Loki bucket Job
  loki_s3_credentials_enabled = local.loki_enabled && local.grafana_enabled && var.loki_storage_type == "s3"
  loki_s3_credentials_data = {
    credentials = "[default]\naws_access_key_id = ${var.loki_s3_access_key_id}\naws_secret_access_key = ${var.loki_s3_secret_access_key}\n"
  }
}

# Create a secret for each database credential dynamically
resource "kubernetes_secret_v1" "database_credentials" {
  count = local.postgres_enabled ? length(var.database_credentials) : 0
  metadata {
    name      = var.database_credentials[count.index].secret-name
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode([var.database_credentials[count.index].username, var.database_credentials[count.index].password])), 0, 62)
    }
  }

  immutable = true

  data = {
    (var.database_credentials[count.index].secret-key-user)     = var.database_credentials[count.index].username
    (var.database_credentials[count.index].secret-key-password) = var.database_credentials[count.index].password
  }

  lifecycle {
    ignore_changes = [data]
  }
}

resource "kubernetes_secret_v1" "postgresql_tls_certificates" {
  count = local.postgres_enabled ? 1 : 0
  metadata {
    name      = "postgres-tls-secret"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode(local.postgresql_tls_certificates_data)), 0, 62)
    }
  }

  immutable = true

  # Skip the double Base64 Encoding, from user input and from Secret Object
  data = local.postgresql_tls_certificates_data
}

resource "kubernetes_secret_v1" "pgbouncer_userlist" {
  count = local.postgres_enabled ? 1 : 0
  metadata {
    name      = "pgbouncer-userlist-secret"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(local.userlist_content), 0, 61)
    }
  }

  immutable = true

  # Create a list of usernames and passwords for pgbouncer
  data = {
    "userlist.txt" = local.userlist_content
  }
}

resource "kubernetes_secret_v1" "object_storage_service_credentials" {
  count = local.object_storage_service_enabled ? 1 : 0
  metadata {
    name      = local.object_storage_service_secret_name
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode(local.object_storage_service_credentials_data)), 0, 62)
    }
  }

  immutable = true

  data = local.object_storage_service_credentials_data

  lifecycle {
    precondition {
      condition     = var.loki_s3_sse_type != "SSE-S3" || local.object_storage_service_sse_enabled
      error_message = "loki_s3_sse_type = \"SSE-S3\" requires object_storage_service_sse_passphrase."
    }
    precondition {
      condition     = var.loki_s3_sse_type != "SSE-KMS"
      error_message = "The own object-storage-service has no KMS configured, loki_s3_sse_type = \"SSE-KMS\" needs an object storage with KMS."
    }
  }
}

resource "kubernetes_secret_v1" "loki_s3_credentials" {
  count = local.loki_s3_credentials_enabled ? 1 : 0
  metadata {
    name      = "loki-bucket-credentials"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode(local.loki_s3_credentials_data)), 0, 62)
    }
  }

  immutable = true

  data = local.loki_s3_credentials_data
}
