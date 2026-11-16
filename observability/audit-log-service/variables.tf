variable "target_namespace" {
  description = "Namespace where to install the Audit Log Service"
  type        = string
  default     = "observability"
}

variable "deployment_information" {
  description = "Deployment information of the Audit Log Service from the active-versions.yaml (as for modules/helm_deployment)"
  type        = any
}

variable "istio_routing_deployment_information" {
  description = "Deployment information of the istio-routing chart from the active-versions.yaml, creates the Service of the Audit Log Service"
  type        = any
  validation {
    condition     = try(length(var.istio_routing_deployment_information.main.version) > 0, false)
    error_message = "The active-versions.yaml needs an 'istio-routing' entry with main.version for the Audit Log Service"
  }
}

variable "helm_repository" {
  description = "Helm Chart Repository URL or repository name of the Audit Log Service"
  type        = string
}

variable "helm_username" {
  description = "Username for the Helm Chart Repository"
  type        = string
  default     = null
  sensitive   = true
}

variable "helm_password" {
  description = "Password for the Helm Chart Repository"
  type        = string
  default     = null
  sensitive   = true
}

variable "docker_registry" {
  description = "Docker registry of the Audit Log Service image"
  type        = string
}

variable "image_pull_secrets" {
  description = "Names of the image pull secrets in the target namespace"
  type        = list(string)
  default     = []
}

variable "replica_count" {
  description = "Number of Audit Log Service replicas"
  type        = number
  default     = 1
}

variable "filter_namespace" {
  description = "Namespace of the ext_proc EnvoyFilters; the Istio root namespace, so they reach the audited namespace"
  type        = string
  default     = "istio-system"
}

variable "audited_namespace" {
  description = "Namespace of the audited workloads (fhir-storage-reader/-writer)"
  type        = string
  default     = "demis"
}

variable "fssr_enabled" {
  description = "Audits the read access of the fhir-storage-reader"
  type        = bool
  default     = false
}

variable "fssw_enabled" {
  description = "Audits the write access of the fhir-storage-writer"
  type        = bool
  default     = false
}
