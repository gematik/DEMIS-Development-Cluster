#########################
# Application Configuration Options
#########################


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
