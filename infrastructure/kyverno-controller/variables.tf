variable "namespace" {
  description = "Namespace where to install Kyverno"
  type        = string
  default     = "kyverno"
}

variable "helm_repository" {
  description = "The Helm Chart Repository for Kyverno"
  type        = string
  default     = "https://kyverno.github.io/kyverno/"
  nullable    = false
}

variable "chart_version" {
  description = "The Helm Chart Version for Kyverno"
  type        = string
  default     = "3.5.3"
}

variable "admissioncontroller_replicas" {
  description = "setting replicas of admission controller"
  type        = number
  default     = 3
}

variable "backgroundcontroller_replicas" {
  description = "setting replicas of background controller"
  type        = number
  default     = 2
}

variable "cleanupcontroller_replicas" {
  description = "setting replicas of cleanup controller"
  type        = number
  default     = 2
}

variable "reportscontroller_replicas" {
  description = "setting replicas of reports controller"
  type        = number
  default     = 2
}

variable "enabled" {
  description = "Deploys Kyverno; namespace and pull secrets are created in any case"
  type        = bool
  default     = true
}

variable "docker_pull_secrets" {
  description = "Pull Secrets for the Kyverno images (see docker_pull_secrets of the infrastructure)"
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
