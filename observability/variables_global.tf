#########################
# Global Settings
#########################

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file of the cluster"
  type        = string
  default     = "~/.kube/config"
}

variable "kms_encryption_key" {
  description = "The GCP KMS encryption key for OpenTofu state encryption"
  type        = string
  default     = ""
  validation {
    condition     = length(var.kms_encryption_key) > 0 ? startswith(var.kms_encryption_key, "projects/") : true
    error_message = "Invalid KMS encryption key format, must start with 'projects/...'"
  }
}

variable "override_stage_name" {
  description = "Override the stage name detected from the cluster labels (local or <cluster>-<region>), used for the stage folder of the active-versions.yaml"
  type        = string
  default     = ""
}

variable "helm_repository_source" {
  description = "Where Helm Charts are resolved from: 'url' uses the public repository URLs and demis_helm_repository, 'local' uses the repository names from helm_repository_names in the Helm repositories.yaml"
  type        = string
  default     = "url"
  validation {
    condition     = contains(["url", "local"], var.helm_repository_source)
    error_message = "helm_repository_source must be either 'url' or 'local'"
  }
}

variable "helm_repository_names" {
  type = object({
    kiali      = optional(string, "kiali")
    prometheus = optional(string, "prometheus-community")
    loki       = optional(string, "grafana-community")
    demis      = optional(string, "demis")
  })
  description = "Repository names in the Helm repositories.yaml per chart, used if helm_repository_source is 'local'"
  default     = {}
}

variable "demis_helm_repository" {
  type        = string
  default     = null
  description = "Helm Repository URL of the DEMIS charts (Audit Log Service, istio-routing), used if helm_repository_source is 'url'"
}

variable "project_feature_flags" {
  type        = map(bool)
  description = "Project feature flags: FEATURE_FLAG_OBSERVABILITY_NAMESPACE_ENABLED switches from the legacy observability in the infrastructure to this module (same value as in the infrastructure), FEATURE_FLAG_AUDIT_LOG_FSSR_ENABLED / FEATURE_FLAG_AUDIT_LOG_FSSW_ENABLED switch the Audit Log Service"
  default     = {}
}

variable "namespace" {
  description = "Namespace that is created for the observability services"
  type        = string
  default     = "observability"
}


variable "docker_registry" {
  description = "Docker registry of the DEMIS images (Audit Log Service, object-storage-service, postgres, pgbouncer)"
  type        = string
  default     = "europe-west3-docker.pkg.dev/gematik-all-infra-prod/demis-dev"
  validation {
    condition     = strcontains(var.docker_registry, "docker.io/gematik1") || startswith(var.docker_registry, "europe-west3-docker.pkg.dev/gematik-all-infra-prod/demis")
    error_message = "Unsupported Docker Registry provided"
  }
}
