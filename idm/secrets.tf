locals {
  ca_certificates = tomap({
    "root-ca.crt" = var.root_ca_certificate
    "sub-ca.crt"  = var.sub_ca_certificate
  })
  test_certificates = { for name, cus_cert in var.cus_health_department_certificates : name => cus_cert }
}


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

resource "kubernetes_secret" "keycloak_admin_account" {
  metadata {
    name      = "keycloak-admin-password"
    namespace = module.demis_namespace.name
  }

  immutable = true

  data = {
    KEYCLOAK_ADMIN          = var.keycloak_admin_user
    KEYCLOAK_ADMIN_PASSWORD = var.keycloak_admin_password
  }
}

resource "kubernetes_secret" "keycloak_portal_secret" {
  metadata {
    name      = "keycloak-portal-secret"
    namespace = module.demis_namespace.name
  }

  immutable = true

  data = {
    KEYCLOAK_PORTAL_ADMIN_PASSWORD = var.keycloak_portal_admin_password
    KEYCLOAK_PORTAL_CLIENT_SECRET  = var.keycloak_portal_client_secret
  }
}

# TODO: Read from file

resource "kubernetes_secret" "keycloak_truststore_file" {
  metadata {
    name      = "keycloak-truststore-file"
    namespace = module.demis_namespace.name
  }

  immutable = true

  binary_data = {
    "truststore.jks" = var.keycloak_truststore_jks
  }
}

resource "kubernetes_secret" "keycloak_truststore_password" {
  metadata {
    name      = "keycloak-truststore-password"
    namespace = module.demis_namespace.name
  }

  immutable = true

  data = {
    KC_SPI_TRUSTSTORE_FILE_PASSWORD = var.keycloak_truststore_password
  }
}

resource "kubernetes_secret" "ldap_certificates" {
  metadata {
    name      = "ldap-certificates"
    namespace = module.demis_namespace.name
  }

  immutable = true

  binary_data = merge(local.ca_certificates, local.test_certificates)
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

resource "kubernetes_secret" "redis_cus_writer_credentials" {
  metadata {
    name      = "redis-cus-writer-password"
    namespace = module.demis_namespace.name
  }

  immutable = true

  data = {
    REDIS_USER     = var.redis_cus_writer_user
    REDIS_PASSWORD = var.redis_cus_writer_password
  }
}

resource "kubernetes_secret" "redis_cus_acl" {
  metadata {
    name      = "redis-cus-acl"
    namespace = module.demis_namespace.name
  }

  immutable = true

  # Defines a User Access Control List with username / permitted operations / sha256 of Password (BITWARDEN)
  data = {
    "users.acl" = <<EOF
      user default on ~* &* +@all #${sha256(var.redis_cus_writer_password)}
      user ${var.redis_cus_writer_user} on ~* &* +@all #${sha256(var.redis_cus_writer_password)}
      user ${var.redis_cus_reader_user} on ~* &* +@all #${sha256(var.redis_cus_reader_password)}
    EOF
  }
}
