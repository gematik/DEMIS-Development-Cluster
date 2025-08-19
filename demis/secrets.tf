#####################
# Database Secrets
#####################

# Create a secret for each database credential dynamically
resource "kubernetes_secret" "database_credentials" {
  count = length(var.database_credentials)
  metadata {
    name      = var.database_credentials[count.index].secret-name
    namespace = module.demis_namespace.name
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


resource "kubernetes_secret" "postgresql_tls_certificates" {
  metadata {
    name      = "postgres-tls-secret"
    namespace = module.demis_namespace.name
  }

  immutable = true

  # Skip the double Base64 Encoding, from user input and from Secret Object
  data = {
    "server.key" : base64decode(var.postgres_server_key)
    "server.crt" : base64decode(var.postgres_server_certificate)
    "ca.crt" : base64decode(var.postgres_root_ca_certificate)
  }
}

resource "kubernetes_secret" "pgbouncer_userlist" {
  metadata {
    name      = "pgbouncer-userlist-secret"
    namespace = module.demis_namespace.name
  }

  immutable = true

  # Create a list of usernames and passwords for pgbouncer
  data = {
    "userlist.txt" = join("\n", [for cred in var.database_credentials : "\"${cred.username}\" \"${cred.password}\""])
  }
}

resource "kubernetes_secret" "notification_gateway_passwords" {
  metadata {
    name      = "notification-gateway-passwords"
    namespace = module.demis_namespace.name
  }

  immutable = true

  data = {
    AUTH_CERT_PASSWORD      = var.gateway_auth_cert_password
    TEST_AUTH_CERT_PASSWORD = var.gateway_test_auth_cert_password
    TRUSTSTORE_PASSWORD     = var.gateway_truststore_password
    TOKEN_CLIENT_LAB        = var.gateway_token_client_lab
  }
}

resource "kubernetes_secret" "notification_gateway_keystores" {
  metadata {
    name      = "notification-gateway-keystores"
    namespace = module.demis_namespace.name
  }

  immutable = true

  binary_data = {
    "truststore.jks"    = var.gateway_truststore_jks
    "keystore.p12"      = var.gateway_keystore_p12
    "test_keystore.p12" = var.gateway_test_keystore_p12
  }
}

resource "kubernetes_secret" "igs_encryption_certificate" {
  metadata {
    name      = "igs-secret"
    namespace = module.demis_namespace.name
  }

  immutable = true

  # Certificate must be configured as base64 directly in the application
  data = {
    S3_STORAGE_TLS_CERTIFICATE          = var.storage_tls_certificate
    S3_STORAGE_TLS_CERTIFICATE_INTERNAL = var.s3_tls_credential
  }
}

resource "kubernetes_secret" "minio_credentials" {
  metadata {
    name      = "minio-secret"
    namespace = module.demis_namespace.name
  }

  immutable = true

  data = {
    MINIO_ROOT_USER     = var.minio_root_user
    MINIO_ROOT_PASSWORD = var.minio_root_password
  }
}

resource "kubernetes_secret" "redis_cus_reader_credentials" {
  metadata {
    name      = "redis-cus-reader-password"
    namespace = module.demis_namespace.name
  }

  immutable = true

  data = {
    REDIS_USER     = var.redis_cus_reader_user
    REDIS_PASSWORD = var.redis_cus_reader_password
  }
}

resource "kubernetes_secret" "ars_pseudo_hash_pepper" {
  count = var.ars_pseudo_hash_pepper == null ? 0 : 1

  metadata {
    name      = "ars-pseudo-hash-pepper"
    namespace = module.demis_namespace.name
  }

  immutable = true

  data = {
    ARS_PSEUDO_HASH_PEPPER = var.ars_pseudo_hash_pepper
  }
}

resource "kubernetes_secret" "gcp_service_accounts" {
  count = length(var.gcp_service_accounts)

  metadata {
    name      = var.gcp_service_accounts[count.index].secret_name
    namespace = module.demis_namespace.name
  }

  data = {
    "keyfile.json" = base64decode(var.gcp_service_accounts[count.index].keyfile_base64)
  }

  immutable = true
}


