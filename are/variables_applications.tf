#########################
# Application Configuration
#########################

# Debugging 
variable "debug_enabled" {
  type        = bool
  description = "Defines if the backend Java Services must be started in Debug Mode"
  default     = false
}

variable "profile_provisioning_mode_vs_are" {
  description = "Provisioning mode for the FHIR Profiles services. Allowed values are: dedicated, distributed, combined"
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.profile_provisioning_mode_vs_are == null || contains(["dedicated", "distributed", "combined"], var.profile_provisioning_mode_vs_are)
    error_message = "The provisioning mode must be one of the following: dedicated, distributed, combined"
  }
}
