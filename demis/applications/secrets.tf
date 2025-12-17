#####################
# Database Secrets
#####################

locals {
  minio_credentials_data = {
    MINIO_ROOT_USER     = var.minio_root_user
    MINIO_ROOT_PASSWORD = var.minio_root_password
  }

  postgresql_tls_certificates_data = {
    "server.key" : base64decode(var.postgres_server_key)
    "server.crt" : base64decode(var.postgres_server_certificate)
    "ca.crt" : base64decode(var.postgres_root_ca_certificate)
  }

  # PGBouncer Specific Secrets
  userlist_content = join("\n", [for cred in var.database_credentials : "\"${cred.username}\" \"${cred.password}\""])

  igs_encryption_certificate_data = {
    S3_STORAGE_TLS_CERTIFICATE          = var.storage_tls_certificate
    S3_STORAGE_TLS_CERTIFICATE_INTERNAL = var.s3_tls_credential
  }

  redis_cus_reader_password_data = {
    REDIS_USER     = var.redis_cus_reader_user
    REDIS_PASSWORD = var.redis_cus_reader_password
  }
}

# Create a secret for each database credential dynamically
resource "kubernetes_secret_v1" "database_credentials" {
  count = length(var.database_credentials)
  metadata {
    name      = var.database_credentials[count.index].secret-name
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode([var.database_credentials[count.index].username, var.database_credentials[count.index].password])), 0, 62)
    }
  }

  immutable = true

  data = {
    var.database_credentials[count.index].secret-key-user     = var.database_credentials[count.index].username
    var.database_credentials[count.index].secret-key-password = var.database_credentials[count.index].password
  }

  lifecycle {
    ignore_changes = [data]
  }
}

resource "kubernetes_secret_v1" "postgresql_tls_certificates" {
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

resource "kubernetes_secret_v1" "minio_credentials" {
  metadata {
    name      = "minio-secret"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode(local.minio_credentials_data)), 0, 62)
    }
  }

  immutable = true

  data = local.minio_credentials_data
}


resource "kubernetes_secret_v1" "ars_pseudo_hash_pepper" {
  count = var.ars_pseudo_hash_pepper == null ? 0 : 1

  metadata {
    name      = "ars-pseudo-hash-pepper"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(var.ars_pseudo_hash_pepper), 0, 61)
    }
  }

  immutable = true

  data = {
    ARS_PSEUDO_HASH_PEPPER = var.ars_pseudo_hash_pepper
  }
}

resource "kubernetes_secret_v1" "pgbouncer_userlist" {
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

resource "kubernetes_secret_v1" "igs_encryption_certificate" {
  metadata {
    name      = "igs-secret"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode(local.igs_encryption_certificate_data)), 0, 61)
    }
  }

  immutable = true

  # Certificate must be configured as base64 directly in the application
  data = local.igs_encryption_certificate_data
}

resource "kubernetes_secret_v1" "redis_cus_reader_credentials" {
  metadata {
    name      = "redis-cus-reader-password"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode(local.redis_cus_reader_password_data)), 0, 61)
    }
  }

  immutable = true

  data = local.redis_cus_reader_password_data
}

resource "kubernetes_secret_v1" "service_accounts" {
  for_each = {
    for sa in var.service_accounts : sa.secret_name => sa
  }

  metadata {
    name      = each.value.secret_name
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(each.value.keyfile_base64), 0, 61)
    }
  }

  binary_data = {
    "keyfile.json" = each.value.keyfile_base64
  }

  immutable = true
}
