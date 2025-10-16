variable "namespace" {
  description = "Namespace where to install the the Trivy Operator"
  type        = string
  default     = "security"
}

variable "helm_repository" {
  description = "The Helm Chart Repository for Trivy Operator"
  type        = string
  default     = "oci://ghcr.io/aquasecurity/helm-charts/"
}

variable "chart_version" {
  description = "The Helm Chart Version for Trivy Operator"
  type        = string
  default     = "0.23.3"
}

variable "cron_job_schedule" {
  description = "Specifies the execution period for the scan"
  type        = string
  default     = "0 */6 * * *"
}

variable "additional_report_fields" {
  description = "Comma separated list of additional fields which can be added to the VulnerabilityReport. Supported parameters: Description, Links, CVSS, Target, Class, PackagePath and PackageType"
  type        = string
  default     = "Description,Links,CVSS,Target,Class,PackagePath,PackageType"
}

variable "scan_namespaces" {
  description = "Comma separated list of Namespaces to be scanned by Trivy"
  type        = string
  default     = "demis"
}

variable "ignore_unfixed" {
  description = "Specifies that Trivy should show only fixed vulnerabilities, if set to true"
  type        = bool
  default     = false
}

variable "use_less_resources" {
  description = "Specifies that Trivy should use less CPU/memory for scanning though it takes more time than normal scanning"
  type        = bool
  default     = true
}

variable "severity_levels" {
  description = "Comma separated list of Namespaces to be scanned by Trivy"
  type        = string
  default     = "UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL"
}

variable "private_registry_secret_names" {
  description = "Map of namespace:token, tokens are comma seperated which can be used to authenticate in private registries in case if there no imagePullSecrets provided"
  type = list(object({
    namespace = string
    token     = string
  }))
  default = []
}

variable "scan_jobs_limit" {
  description = "Defines the maximum number of scan jobs create by the operator"
  type        = string
  default     = "3"
}