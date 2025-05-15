########### Policy Reporter Settings ############

variable "namespace" {
  description = "Namespace where to install Kyverno Policy Reporter"
  type        = string
  default     = "security"
}

variable "helm_repository" {
  description = "The Helm Chart Repository for Kyverno Policy Reporter"
  type        = string
  default     = "https://kyverno.github.io/policy-reporter"
}

variable "chart_version" {
  description = "The Helm Chart Version for Kyverno Policy Reporter"
  type        = string
  default     = "2.24.1"
}
