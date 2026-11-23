variable "target_namespace" {
  description = "Namespace where to install the services"
  type        = string
  default     = "observability"
}

variable "grafana_helm_repository" {
  description = "The OCI Helm Repository to download the Grafana Chart"
  type        = string
  default     = "oci://ghcr.io/grafana-community/helm-charts"
  nullable    = false
  # The chart is pinned by its OCI digest
  validation {
    condition     = startswith(var.grafana_helm_repository, "oci://")
    error_message = "The Grafana Helm Repository must be an OCI registry (oci://)"
  }
}

variable "grafana_version" {
  description = "The version of the Grafana Chart to be installed"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.grafana_version))
    error_message = "The Grafana version must be provided in a valid Semantic Version format (e.g., 1.2.3)"
  }
}

variable "grafana_digest" {
  description = "The OCI digest of the Grafana Chart version"
  type        = string
  validation {
    condition     = can(regex("^sha256:[a-f0-9]{64}$", var.grafana_digest))
    error_message = "The Grafana digest must be a valid SHA256 digest"
  }
}

variable "istio_version" {
  description = "The version of the Istio Services for downloading the correct dashboards"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.istio_version))
    error_message = "The Istio version must be provided in a valid Semantic Version format (e.g., 1.2.3)"
  }
}

variable "prometheus_enabled" {
  description = "Defines if the Prometheus datasource and the dashboards (all based on Prometheus) have to be added to Grafana"
  type        = bool
  default     = false
}

variable "prometheus_service_url" {
  description = "Cluster-internal URL of Prometheus, used for the Grafana Prometheus datasource (only relevant when prometheus_enabled is true)"
  type        = string
  default     = ""
}

variable "loki_enabled" {
  description = "Defines if a Loki datasource has to be added to Grafana"
  type        = bool
  default     = false
}

variable "fetched_notifications_datasource" {
  description = "PostgreSQL datasource on the fetched_notifications database (Audit Log Service) via pgbouncer, read with the Grafana reader user; null disables it"
  type = object({
    host                = string
    port                = number
    secret_name         = string
    secret_key_user     = string
    secret_key_password = string
  })
  default = null
}

variable "loki_service_url" {
  description = "Cluster-internal base URL of the Loki service, used for the Grafana Loki datasource (only relevant when loki_enabled is true)"
  type        = string
  default     = "http://loki:3100"
}

variable "resource_definitions" {
  description = "Per workload of the module (output of the resources module): replicas, resource block (YAML) and Istio proxy resources; null or missing keeps the defaults"
  type = map(object({
    replicas       = optional(number)
    resource_block = optional(string)
    istio_proxy_resources = optional(object({
      limits   = optional(map(string), {})
      requests = optional(map(string), {})
    }))
  }))
  default = {}
}
