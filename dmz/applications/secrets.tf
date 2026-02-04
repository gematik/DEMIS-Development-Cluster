locals {
  postgresql_tls_certificates_data = {
    "server.key" : base64decode(var.postgres_server_key)
    "server.crt" : base64decode(var.postgres_server_certificate)
    "ca.crt" : base64decode(var.postgres_root_ca_certificate)
  }

  pgbouncer_userlist_content = join("\n", [for cred in var.database_credentials : "\"${cred.username}\" \"${cred.password}\""])
}

#####################
# Database Secrets
#####################

# Create a secret for each database credential dynamically
resource "kubernetes_secret_v1" "database_credentials" {
  count = length(var.database_credentials)
  metadata {
    name      = var.database_credentials[count.index].secret-name
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode([var.database_credentials[count.index].username, var.database_credentials[count.index].password])), 0, 61)
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
      checksum = substr(sha256(jsonencode(local.postgresql_tls_certificates_data)), 0, 61)
    }
  }

  immutable = true

  # Skip the double Base64 Encoding, from user input and from Secret Object
  data = local.postgresql_tls_certificates_data
}

resource "kubernetes_secret_v1" "pgbouncer_userlist" {
  metadata {
    name      = "pgbouncer-userlist-secret"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(local.pgbouncer_userlist_content), 0, 61)
    }
  }

  immutable = true

  # Create a list of usernames and passwords for pgbouncer
  data = {
    "userlist.txt" = local.pgbouncer_userlist_content
  }
}

resource "kubernetes_secret_v1" "ars_bulk_upload_hmac_secret" {
  metadata {
    name      = "ars-bulk-upload-hmac-secret"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(var.ars_bulk_upload_hmac_secret), 0, 61)
    }
  }

  immutable = true

  data = {
    ARS_BULK_UPLOAD_HMAC_SECRET = var.ars_bulk_upload_hmac_secret
  }

}