variable "service_accounts" {
  description = "Service account details for authentication"
  type = list(object({
    secret_name    = string # Name of the Kubernetes secret to store the service account key
    keyfile_base64 = string # Base64-encoded JSON key file content
  }))
  default = []
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

variable "ars_pseudo_hash_pepper" {
  type        = string
  sensitive   = true
  description = "The Pepper used for the ARS Pseudo Hashing (Base64-encoded)"
  default     = null
}
