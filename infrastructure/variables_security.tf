#########################
# General Security Settings
#########################

variable "security_namespace" {
  type        = string
  default     = "security"
  description = "Defines the namespace for the Security-related services"
}

########################
# Trivy Module
#########################

variable "trivy_enabled" {
  type        = bool
  default     = false
  description = "Activates/Deactivates the deployment of Trivy Operator"
}

variable "trivy_cron_job_schedule" {
  description = "Specifies the execution period for the scan for Trivy"
  type        = string
  default     = "0 */6 * * *"
}

variable "trivy_additional_report_fields" {
  description = "Comma separated list of additional fields which can be added to the VulnerabilityReport. Supported parameters: Description, Links, CVSS, Target, Class, PackagePath and PackageType"
  type        = string
  default     = "Description,Links,CVSS,Target,Class,PackagePath,PackageType"
}

variable "trivy_scan_namespaces" {
  description = "Comma separated list of Namespaces to be scanned by Trivy"
  type        = string
  default     = "demis"
}

variable "trivy_ignore_unfixed" {
  description = "Specifies that Trivy should show only fixed vulnerabilities, if set to true"
  type        = bool
  default     = false
}

variable "trivy_use_less_resources" {
  description = "Specifies that Trivy should use less CPU/memory for scanning though it takes more time than normal scanning"
  type        = bool
  default     = true
}

variable "trivy_severity_levels" {
  description = "Comma separated list of Namespaces to be scanned by Trivy"
  type        = string
  default     = "UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL"
}

variable "trivy_private_registry_secret_names" {
  description = "Map of namespace:token, tokens are comma seperated which can be used to authenticate in private registries in case if there no imagePullSecrets provided"
  type = list(object({
    namespace = string
    token     = string
  }))
  default = []
}

variable "trivy_scan_jobs_limit" {
  description = "Defines the maximum number of scan jobs create by the operator"
  type        = string
  default     = "3"
}

########################
# Falco Module
#########################

variable "falco_enabled" {
  type        = bool
  default     = false
  description = "Activates/Deactivates the deployment of Falco"
}

variable "falco_kubernetes_meta_collector" {
  type        = bool
  default     = true
  description = "enables the k8s metacollector plugin"
}

variable "falco_falcosidekick_enabled" {
  description = "enables falcosidekick"
  type        = bool
  default     = false
}

variable "falco_falcosidekick_ui_enabled" {
  description = "enables falcosidekick"
  type        = bool
  default     = false
}

variable "falco_driver_kind" {
  description = "sets the specfifc driver kind of the probe inside the nodes. Default of Falco is auto. The options are: kmod, ebpf, modern_ebpf, We can enforce that if needed."
  type        = string
  default     = "auto"
}

#########################
# Policy-Reporter Settings
#########################

variable "kyverno_policy_reporter_enabled" {
  type        = bool
  default     = false
  description = "Activates/Deactivates the deployment of Policy Reporter"
}