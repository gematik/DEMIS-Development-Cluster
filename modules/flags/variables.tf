# Feature Flags are boolean values that are used to enable or disable features in the application
variable "feature_flags" {
  type = list(object({
    services   = list(string)
    flag_name  = string
    flag_value = bool
  }))
  description = "Defines a list of feature flags that belong to services"
  default     = []

  validation {
    condition     = length(var.feature_flags) > 0 ? alltrue([for ff in var.feature_flags : startswith(ff.flag_name, "FEATURE_FLAG_")]) : true
    error_message = "Feature flags must start with the prefix 'FEATURE_FLAG_'"
  }
}

# Configuration Options contain String values that are used to configure the application
variable "config_options" {
  type = list(object({
    services     = list(string)
    option_name  = string
    option_value = string
  }))
  description = "Defines a list of configuration options that belong to services"
  default     = []

  validation {
    condition     = length(var.config_options) > 0 ? alltrue([for co in var.config_options : length(co.option_name) > 0 && (co.option_value == null || length(co.option_value) >= 0)]) : true
    error_message = "Configuration options must not be empty"
  }
}

variable "all_services" {
  type        = list(string)
  description = "List of all services in the deployment"
  default     = []

  validation {
    condition     = length(setsubtract(distinct(flatten([for ff in var.feature_flags : ff.services])), concat(var.all_services, ["all"]))) == 0
    error_message = "there are feature flags defined for services that are not in the all_services list: ${jsonencode(setsubtract(distinct(flatten([for ff in var.feature_flags : ff.services])), concat(var.all_services, ["all"])))}"
  }
  validation {
    condition     = length(setsubtract(distinct(flatten([for co in var.config_options : co.services])), concat(var.all_services, ["all"]))) == 0
    error_message = "there are config options defined for services that are not in the all_services list: ${jsonencode(setsubtract(distinct(flatten([for co in var.config_options : co.services])), concat(var.all_services, ["all"])))}"
  }
}
