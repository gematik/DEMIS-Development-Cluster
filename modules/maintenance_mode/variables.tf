# Deployment specific Information provided from the Stage "active-versions.yaml" file
variable "deployment_information" {
  description = "Structure holding deployment information for the Helm Charts"
  type = map(object({
    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name
    deployment-strategy = string
    enabled             = bool
    main = object({
      version = string
      weight  = number
    })
    canary = optional(object({
      version = optional(string)
      weight  = optional(string)
    }), {})
  }))
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file for the cluster"
  type        = string
  default     = ""
  nullable    = false
  validation {
    condition     = length(var.kubeconfig_path) > 0 ? fileexists(var.kubeconfig_path) : true
    error_message = "The provided kubeconfig file does not exist"
  }
}

variable "activate_maintenance_mode" {
  type        = bool
  description = "Boolean value whether to activate (true) or deactivate (false) the maintenance mode"
}
