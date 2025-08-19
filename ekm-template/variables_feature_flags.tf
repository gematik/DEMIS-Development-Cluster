#########################
# Application Flags
#########################

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
