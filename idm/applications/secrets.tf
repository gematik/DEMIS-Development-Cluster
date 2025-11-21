locals {
  ca_certificates = tomap({
    "root-ca.crt" = var.root_ca_certificate
    "sub-ca.crt"  = var.sub_ca_certificate
  })
  test_certificates = { for name, cus_cert in var.cus_health_department_certificates : name => cus_cert }

  ldap_certificates = merge(local.ca_certificates, local.test_certificates)

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
resource "kubernetes_secret" "database_credentials" {
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

resource "kubernetes_secret" "postgresql_tls_certificates" {
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

resource "kubernetes_secret" "pgbouncer_userlist" {
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

resource "kubernetes_secret" "keycloak_admin_account" {
  metadata {
    name      = "keycloak-admin-password"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode([var.keycloak_admin_user, var.keycloak_admin_password])), 0, 61)
    }
  }

  immutable = true

  data = {
    KEYCLOAK_ADMIN          = var.keycloak_admin_user
    KEYCLOAK_ADMIN_PASSWORD = var.keycloak_admin_password
  }
}

resource "kubernetes_secret" "keycloak_cus_client_secret" {
  metadata {
    name      = "keycloak-cus-client-secret"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(var.keycloak_cus_client_secret), 0, 61)
    }
  }

  immutable = true

  data = {
    KC_CUS_CLI_SECRET = var.keycloak_cus_client_secret
  }
}

resource "kubernetes_secret" "keycloak_portal_secret" {
  metadata {
    name      = "keycloak-portal-secret"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode([var.keycloak_portal_admin_password, var.keycloak_portal_client_secret])), 0, 61)
    }
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
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(var.keycloak_truststore_jks), 0, 61)
    }
  }

  immutable = true

  binary_data = {
    "truststore.jks" = var.keycloak_truststore_jks
  }
}

resource "kubernetes_secret" "keycloak_truststore_password" {
  metadata {
    name      = "keycloak-truststore-password"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(var.keycloak_truststore_password), 0, 61)
    }
  }

  immutable = true

  data = {
    KC_SPI_TRUSTSTORE_FILE_PASSWORD = var.keycloak_truststore_password
  }
}


resource "kubernetes_secret" "ldap_certificates" {
  metadata {
    name      = "ldap-certificates"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode(local.ldap_certificates)), 0, 61)
    }
  }

  immutable = true

  binary_data = local.ldap_certificates
}

resource "kubernetes_secret" "redis_cus_reader_credentials" {
  metadata {
    name      = "redis-cus-reader-password"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode([var.redis_cus_reader_user, var.redis_cus_reader_password])), 0, 61)
    }
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
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode([var.redis_cus_writer_user, var.redis_cus_writer_password])), 0, 61)
    }
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
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode([var.redis_cus_reader_user, var.redis_cus_reader_password, var.redis_cus_writer_user, var.redis_cus_writer_password])), 0, 61)
    }
  }

  immutable = true

  # Defines a User Access Control List with username / permitted operations / sha256 of Password (BITWARDEN)
  data = {
    "users.acl" = <<EOF
      user default off
      user ${var.redis_cus_writer_user} on ~* &* +@write +@read #${sha256(var.redis_cus_writer_password)}
      user ${var.redis_cus_reader_user} on ~* &* +@read +info #${sha256(var.redis_cus_reader_password)}
    EOF
  }
}
