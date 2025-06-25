#########################
# Helm Repository Credentials
#########################

variable "helm_repository_username" {
  type        = string
  sensitive   = true
  description = "The Username credential for the Helm Repository"
  default     = ""
}

variable "helm_repository_password" {
  type        = string
  sensitive   = true
  description = "The Password credential for the Helm Repository"
  default     = ""
}

###########################################
# Google Artifact Hub / Docker Registries
###########################################

variable "google_cloud_access_token" {
  sensitive   = true
  type        = string
  default     = ""
  description = <<EOT
  The User-Token for accessing the Google Artifact Registry. 
  Typically obtained with the command: 'gcloud auth print-access-token'
  EOT
}

variable "docker_pull_secrets" {
  type = list(object({
    name          = string
    registry      = string
    user_name     = string
    user_email    = string
    user_password = string
    password_type = string
  }))
  description = <<EOT
  This Object contains the definition of Pull Secrets for accessing private repositories and pull Docker Images, using credentials.

  For credentials-based secrets, if the field "password_type" is "token", 
  then the value of the variable "google_cloud_access_token" will be used instead.

  If the field "password_type" is set to "json_key", the value of the field "user_password" will be used as a Base64-encoded JSON Key.
  EOT
  default     = []

  validation {
    condition     = length(var.docker_pull_secrets) > 0 ? alltrue([for cred in var.docker_pull_secrets : cred.registry != "" && cred.user_name != "" && contains(["json_key", "token", "plain"], cred.password_type)]) : true
    error_message = "You must provide valid credentials for the Docker Pull Secrets"
  }
}

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

variable "keycloak_gematik_idp_public_key" {
  type        = string
  sensitive   = true
  description = "The gematik idp public key for Keycloak in Base64 Format"
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
