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
###########################################
# Loki - External S3 Object Storage
###########################################

variable "loki_s3_access_key_id" {
  sensitive   = true
  type        = string
  default     = ""
  description = <<-EOT
  The S3 access key id used by Loki when service_mesh_loki_storage_type is "s3".
  Leave empty to rely on an IAM role / instance profile (workload identity).
  EOT
}

variable "loki_s3_secret_access_key" {
  sensitive   = true
  type        = string
  default     = ""
  description = <<-EOT
  The S3 secret access key used by Loki when service_mesh_loki_storage_type is "s3".
  Leave empty to rely on an IAM role / instance profile (workload identity).
  EOT
}
