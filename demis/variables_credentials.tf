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
variable "ncapi_apikey" {
  type        = string
  sensitive   = true
  description = "The API Key for the NCAPI Service"
}

# Notification Gateway Credentials
variable "gateway_auth_cert_password" {
  type        = string
  sensitive   = true
  description = "The Password for the Gateway Auth Certificate"
}

variable "gateway_test_auth_cert_password" {
  type        = string
  sensitive   = true
  description = "The Password for the Gateway Test Auth Certificate"
}

variable "gateway_truststore_password" {
  type        = string
  sensitive   = true
  description = "The Password for the Gateway Truststore"
}

variable "gateway_token_client_lab" {
  type        = string
  sensitive   = true
  description = "The Client Token for the Gateway LAB Realm"
}

# Gateway Truststore JKS as Base64
variable "gateway_truststore_jks" {
  type        = string
  sensitive   = true
  description = "The Truststore JKS for the Gateway"
}

# Gateway Keystore JKS as Base64
variable "gateway_keystore_p12" {
  type        = string
  sensitive   = true
  description = "The Keystore P12 for the Gateway"
}

# Gateway Test Keystore JKS as Base64
variable "gateway_test_keystore_p12" {
  type        = string
  sensitive   = true
  description = "The Test Keystore P12 for the Gateway"
}

# CA certificate of storage when accessing externally
variable "storage_tls_certificate" {
  type        = string
  sensitive   = true
  description = "CA certificate of storage when accessing externally"
}

# CA certificate of storage when accessing internally
variable "s3_tls_credential" {
  type        = string
  sensitive   = true
  description = "Base64-encoded, PEM certificate to be used for configuring the TLS Settings for the S3 Storage Server Connection."
}

# MinIO Credentials
variable "minio_root_user" {
  type        = string
  sensitive   = true
  description = "The Minio Root User"
}

variable "minio_root_password" {
  type        = string
  sensitive   = true
  description = "The Minio Root Password"
}

# Redis CUS Credentials for Notification Processing Service
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
