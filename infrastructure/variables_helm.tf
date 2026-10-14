#########################
# Helm Repository Source
#########################

variable "helm_repository_source" {
  type        = string
  description = "Where Helm Charts are resolved from: 'url' uses the public repository URLs, 'local' uses the repository names from helm_repository_names in the Helm repositories.yaml (credentials and index cache are taken from there)"
  default     = "url"
  validation {
    condition     = contains(["url", "local"], var.helm_repository_source)
    error_message = "helm_repository_source must be either 'url' or 'local'"
  }
}

variable "helm_repository_names" {
  type = object({
    istio           = optional(string, "istio")
    kyverno         = optional(string, "kyverno")
    kiali           = optional(string, "kiali")
    prometheus      = optional(string, "prometheus-community")
    loki            = optional(string, "grafana-community")
    trivy           = optional(string, "aqua")
    falco           = optional(string, "falcosecurity")
    policy_reporter = optional(string, "policy-reporter")
  })
  description = "Repository names in the Helm repositories.yaml per chart, used if helm_repository_source is 'local'"
  default     = {}
}

