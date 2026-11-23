#########################
# Credentials
#########################

variable "database_credentials" {
  description = "Database credentials of postgres (admin and the fetched_notifications users), as database_credentials of the demis module"
  type = list(object({
    username            = string
    password            = string
    secret-name         = string
    secret-key-user     = string
    secret-key-password = string
  }))
  default   = []
  sensitive = true
}

variable "postgres_server_key" {
  description = "Base64 encoded TLS key of the postgres server"
  type        = string
  default     = ""
  sensitive   = true
}

variable "postgres_server_certificate" {
  description = "Base64 encoded TLS certificate of the postgres server"
  type        = string
  default     = ""
  sensitive   = true
}

variable "postgres_root_ca_certificate" {
  description = "Base64 encoded CA certificate, pgbouncer verifies the postgres server against it"
  type        = string
  default     = ""
  sensitive   = true
}

variable "object_storage_service_access_key" {
  description = "Access key of the admin identity of the object-storage-service"
  type        = string
  default     = ""
  sensitive   = true
}

variable "object_storage_service_secret_key" {
  description = "Secret key of the admin identity of the object-storage-service"
  type        = string
  default     = ""
  sensitive   = true
}

variable "object_storage_service_sse_passphrase" {
  description = "Passphrase the object-storage-service derives the SSE-S3 key from; changing it makes all encrypted objects unreadable"
  type        = string
  default     = ""
  sensitive   = true
}

variable "loki_s3_access_key_id" {
  description = "The S3 access key id used when loki_storage_type is s3."
  type        = string
  default     = ""
  sensitive   = true
}

variable "loki_s3_secret_access_key" {
  description = "The S3 secret access key used when loki_storage_type is s3."
  type        = string
  default     = ""
  sensitive   = true
}

variable "demis_helm_repository_username" {
  description = "Username of the DEMIS Helm repository (null for a local repository)"
  type        = string
  default     = null
}

variable "demis_helm_repository_password" {
  description = "Password of the DEMIS Helm repository (null for a local repository)"
  type        = string
  default     = null
  sensitive   = true
}
