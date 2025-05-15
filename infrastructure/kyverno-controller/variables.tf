variable "namespace" {
  description = "Namespace where to install Kyverno"
  type        = string
  default     = "kyverno"
}

variable "helm_repository" {
  description = "The Helm Chart Repository for Kyverno"
  type        = string
  default     = "https://kyverno.github.io/kyverno/"
}

variable "chart_version" {
  description = "The Helm Chart Version for Kyverno"
  type        = string
  default     = "3.3.7"
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