#############################
# DEMIS Database Credentials
#############################

variable "database_credentials" {
  type = list(object({
    username            = string
    password            = string
    secret-name         = string
    secret-key-user     = string
    secret-key-password = string
  }))
  sensitive   = true
  description = "List of Database Credentials for DEMIS services (a secret)"
  default     = []
}

variable "postgres_root_ca_certificate" {
  type        = string
  sensitive   = true
  description = "The Root CA Certificate for the Postgres Database in PEM format, encoded in base64"
}

variable "postgres_server_certificate" {
  type        = string
  sensitive   = true
  description = "The Server Certificate for the Postgres Database in PEM format, encoded in base64"
}

variable "postgres_server_key" {
  type        = string
  sensitive   = true
  description = "The Server Key for the Postgres Database in PEM format, encoded in base64"
}

################################
# DEMIS Application Credentials
################################
variable "keycloak_admin_user" {
  type        = string
  description = "The Admin User for Keycloak"
}

variable "keycloak_admin_password" {
  type        = string
  sensitive   = true
  description = "The Admin Password for Keycloak"
}

variable "keycloak_truststore_password" {
  type        = string
  sensitive   = true
  description = "The Truststore Password for Keycloak"
}

variable "keycloak_truststore_jks" {
  type        = string
  sensitive   = true
  description = "The Truststore JKS for Keycloak in Base64 Format"
}

variable "keycloak_cus_client_secret" {
  type        = string
  sensitive   = true
  description = "client secret of cus-cli (service account) in realm oegd"
}

# Redis CUS Credentials
variable "redis_cus_writer_user" {
  type        = string
  sensitive   = true
  description = "The Redis CUS User (Writer)"
}

variable "redis_cus_writer_password" {
  type        = string
  sensitive   = true
  description = "The Redis CUS Password (Writer)"
}

variable "redis_cus_reader_user" {
  type        = string
  sensitive   = true
  description = "The Redis CUS User (Reader)"
}

variable "redis_cus_reader_password" {
  type        = string
  sensitive   = true
  description = "The Redis CUS Password (Reader)"
}

# LDAP Certificates as Base64
variable "root_ca_certificate" {
  type        = string
  sensitive   = true
  description = "The LDAP Root CA Certificate"
}

variable "sub_ca_certificate" {
  type        = string
  sensitive   = true
  description = "The LDAP Sub CA Certificate"
}

# Keycloak-User-Purger
variable "keycloak_portal_admin_user" {
  type        = string
  description = "The Admin User for Keycloak PORTAL-Realm"
}

variable "keycloak_portal_admin_password" {
  type        = string
  sensitive   = true
  description = "The Admin Password for Keycloak PORTAL-Realm"
}

variable "keycloak_portal_client_id" {
  type        = string
  description = "The Client-ID for Keycloak PORTAL-Realm"
}

variable "keycloak_portal_client_secret" {
  type        = string
  sensitive   = true
  description = "The Client-Secret for Keycloak PORTAL-Realm"
}

variable "cus_health_department_certificates" {
  type        = map(string)
  default     = {}
  description = "Base64-encoded GA certificates for local, ekm and live-test environment"
}
