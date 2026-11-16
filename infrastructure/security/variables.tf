variable "namespace" {
  description = "Namespace that is created for the security services (Trivy, Falco, Policy Reporter)"
  type        = string
  default     = "security"
}

variable "stage_name" {
  description = "Name of the stage, used for the namespace labels"
  type        = string
}

variable "cluster_region" {
  description = "Region of the cluster, used for the namespace labels"
  type        = string
}

variable "trivy_enabled" {
  description = "Deploys Trivy"
  type        = bool
  default     = false
}

variable "trivy_helm_repository" {
  description = "Trivy Helm Chart Repository URL or repository name, null uses the module default"
  type        = string
  default     = null
}

variable "trivy_chart_version" {
  description = "The version of the Trivy Helm Chart"
  type        = string
  default     = "0.23.3"
}

variable "trivy_cron_job_schedule" {
  description = "Cron schedule of the Trivy scans"
  type        = string
  default     = "0 */6 * * *"
}

variable "trivy_additional_report_fields" {
  description = "Additional fields of the Trivy reports"
  type        = string
  default     = "Description,Links,CVSS,Target,Class,PackagePath,PackageType"
}

variable "trivy_scan_namespaces" {
  description = "Namespaces scanned by Trivy"
  type        = string
  default     = "demis"
}

variable "trivy_ignore_unfixed" {
  description = "Ignores vulnerabilities without a fix"
  type        = bool
  default     = false
}

variable "trivy_use_less_resources" {
  description = "Runs Trivy with fewer resources"
  type        = bool
  default     = true
}

variable "trivy_severity_levels" {
  description = "Severity levels reported by Trivy"
  type        = string
  default     = "UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL"
}

variable "trivy_private_registry_secret_names" {
  description = "Namespace and comma separated tokens for private registries without imagePullSecrets"
  type = list(object({
    namespace = string
    token     = string
  }))
  default = []
}

variable "trivy_scan_jobs_limit" {
  description = "Maximum number of parallel Trivy scan jobs"
  type        = string
  default     = "3"
}

variable "falco_enabled" {
  description = "Deploys Falco"
  type        = bool
  default     = false
}

variable "falco_helm_repository" {
  description = "Falco Helm Chart Repository URL or repository name, null uses the module default"
  type        = string
  default     = null
}

variable "falco_chart_version" {
  description = "The version of the Falco Helm Chart"
  type        = string
  default     = "9.2.0"
}

variable "falco_kubernetes_meta_collector" {
  description = "Enables the Kubernetes metadata collector of Falco"
  type        = bool
  default     = true
}

variable "falco_falcosidekick_enabled" {
  description = "Enables Falcosidekick"
  type        = bool
  default     = false
}

variable "falco_falcosidekick_ui_enabled" {
  description = "Enables the Falcosidekick UI"
  type        = bool
  default     = false
}

variable "falco_driver_kind" {
  description = "Falco driver kind"
  type        = string
  default     = "auto"
}

variable "policy_reporter_enabled" {
  description = "Deploys the Kyverno Policy Reporter"
  type        = bool
  default     = false
}

variable "policy_reporter_helm_repository" {
  description = "Policy Reporter Helm Chart Repository URL or repository name, null uses the module default"
  type        = string
  default     = null
}

variable "policy_reporter_chart_version" {
  description = "The version of the Policy Reporter Helm Chart"
  type        = string
  default     = "3.7.2"
}
