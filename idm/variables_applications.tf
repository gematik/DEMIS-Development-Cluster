#########################
# Application Configuration
#########################

# Debugging 
variable "debug_enabled" {
  type        = bool
  description = "Defines if the backend Java Services must be started in Debug Mode"
  default     = false
}

# PGBouncer Database Host
variable "database_target_host" {
  type        = string
  description = "Defines the Hostname of the Database Server"
  validation {
    condition     = length(var.database_target_host) > 0
    error_message = "The Database Hostname must be defined"
  }
}

# Subdomain of TI IDP Mock
variable "ti_idp_subdomain" {
  type        = string
  description = "The URL to access the DEMIS Notification Portal over the Telematikinfrastruktur (TI)"
  default     = "ti-idp"
}

# Server url of TI IDP Mock
variable "ti_idp_server_url" {
  type        = string
  description = "The server url for DEMIS Notification Portal over the Telematikinfrastruktur (TI)"
  default     = ""
}

# Client name of TI IDP Mock
variable "ti_idp_client_name" {
  type        = string
  description = "The client name for access the DEMIS Notification Portal over the Telematikinfrastruktur (TI)"
  default     = ""
}

# Redirect Uri of TI IDP Mock
variable "ti_idp_redirect_uri" {
  type        = string
  description = "The redirect uri to access the DEMIS Notification Portal over the Telematikinfrastruktur (TI)"
  default     = ""
}

# Activation of return sso token of TI IDP Mock
variable "ti_idp_return_sso_token" {
  type        = string
  description = "Activate return sso token for access the DEMIS Notification Portal over the Telematikinfrastruktur (TI)"
  default     = "true"
}

# Stage Configuration Data Version
variable "stage_configuration_data_version" {
  type        = string
  description = "Defines the Version of the Stage Configuration Data to be used in the DEMIS Environment"
  nullable    = true
  default     = null
}

# Stage Configuration Data Name
variable "stage_configuration_data_name" {
  type        = string
  description = "Defines the Name of the Stage Configuration Data to be used in the DEMIS Environment"
  validation {
    condition     = length(var.stage_configuration_data_name) > 0
    error_message = "The Name of the Stage Configuration Data must be defined"
  }
}

variable "certificate_update_service_suspend" {
  type        = bool
  description = "Defines if the certificate-update-service is suspended."
  default     = false
}

# Certificate Update Service Cron Schedule
variable "certificate_update_cron_schedule" {
  type        = string
  description = "Defines the Cron Schedule for the Certificate Update Service"
  validation {
    condition     = length(var.certificate_update_cron_schedule) > 0
    error_message = "The Certificate Update Service Cron Schedule must be defined"
  }
}

variable "keycloak_user_purger_suspend" {
  type        = bool
  description = "Defines if the keycloak-user-purger is suspended."
  default     = false
}

# Keycloak-User-Purger Cron Schedule
variable "keycloak_user_purger_cron_schedule" {
  type        = string
  description = "Defines the Cron Schedule for the Keycloak-User-Purger"
  validation {
    condition     = length(var.keycloak_user_purger_cron_schedule) > 0
    error_message = "The Keycloak-User-Purger Cron Schedule must be defined"
  }
}

# Activation of Keycloak user import
variable "keycloak_user_import_enabled" {
  type        = bool
  description = "Activate Keycloak user import"
  default     = false
}

# Activation of BundID IDP user import
variable "bundid_idp_user_import_enabled" {
  type        = bool
  description = "Activate BundID IDP user import"
  default     = false
}

variable "bundid_idp_issuer_subdomain" {
  type        = string
  description = "The BundID IDP Issuer URL to be used for the JSON Web Token (JWT) validation"
  default     = ""
}
