#########################
# Kyverno Settings
#########################

variable "kyverno_namespace" {
  type        = string
  default     = "kyverno"
  description = "Defines the namespace for Kyverno"
}

variable "kyverno_enabled" {
  type        = bool
  default     = false
  description = "Activates/Deactivates the deployment of Kyverno"
}

variable "kyverno_admissioncontroller_replicas" {
  description = "setting replicas of admission controller"
  type        = number
  default     = 3
}

variable "kyverno_backgroundcontroller_replicas" {
  description = "setting replicas of background controller"
  type        = number
  default     = 2
}

variable "kyverno_cleanupcontroller_replicas" {
  description = "setting replicas of cleanup controller"
  type        = number
  default     = 2
}

variable "kyverno_reportscontroller_replicas" {
  description = "setting replicas of reports controller"
  type        = number
  default     = 2
}