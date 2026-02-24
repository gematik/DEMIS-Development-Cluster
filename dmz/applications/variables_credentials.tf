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

variable "rabbitmq_username" {
  description = "The RabbitMQ username for the application"
  type        = string
}

variable "rabbitmq_password" {
  description = "The RabbitMQ password for the application"
  type        = string
  sensitive   = true
}

variable "rabbitmq_password_hash" {
  description = "The RabbitMQ password hash for the application"
  type        = string
  sensitive   = true
}

variable "rabbitmq_erlang_cookie" {
  description = "The RabbitMQ Erlang cookie for the application"
  type        = string
  sensitive   = true
}