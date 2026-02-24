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

############################
## DEMIS Database Credentials
############################

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