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

variable "ars_bulk_upload_hmac_secret" {
  type        = string
  sensitive   = true
  description = "The secret to generate HMACs from the preferred usernames in the bulk upload service"
  default     = ""
}