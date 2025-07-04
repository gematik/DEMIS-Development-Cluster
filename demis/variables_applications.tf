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

# S3 Storage URL
variable "s3_hostname" {
  type        = string
  description = "The Hostname of the Remote S3 Storage"
  default     = ""
}

variable "s3_port" {
  type        = number
  description = "The Port of the Remote S3 Storage"
  default     = 9000
  validation {
    condition     = var.s3_port > 0 && var.s3_port < 65536
    error_message = "The Port of the Remote S3 Storage must be between 0 and 65535"
  }
}

variable "fhir_storage_purger_suspend" {
  type        = bool
  description = "Defines if the fhir-storage-purger is suspended."
  default     = false
}

variable "fhir_storage_purger_cron_schedule" {
  type        = string
  description = "Defines the cron schedule for the FHIR storage purger"
  validation {
    condition     = length(var.fhir_storage_purger_cron_schedule) > 0
    error_message = "The FHIR storage purger cron schedule must be defined"
  }
}
