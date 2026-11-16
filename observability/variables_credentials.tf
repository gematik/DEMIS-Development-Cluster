variable "helm_repository_username" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The Username credential for the DEMIS Helm Repository, used if helm_repository_source is 'url'"
}

variable "helm_repository_password" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The Password credential for the DEMIS Helm Repository, used if helm_repository_source is 'url'"
}

variable "docker_pull_secrets" {
  description = "Pull Secrets for the Audit Log Service image (see docker_pull_secrets of the infrastructure)"
  type = list(object({
    name          = string
    registry      = string
    user_name     = string
    user_email    = string
    user_password = string
    password_type = string
  }))
  # Not sensitive, it drives for_each (as the infrastructure variable)
  default = []
}

variable "google_cloud_access_token" {
  description = "Access Token used for the Pull Secrets with password_type 'token'"
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
