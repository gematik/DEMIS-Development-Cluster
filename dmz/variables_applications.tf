#########################
# Application Configuration
#########################

# Debugging 
variable "debug_enabled" {
  type        = bool
  description = "Defines if the backend Java Services must be started in Debug Mode"
  default     = false
}

variable "demis_namespace" {
  type        = string
  description = "Defines the Namespace where DEMIS is deployed"
  default     = "demis"
  validation {
    condition     = length(var.demis_namespace) > 0
    error_message = "The DEMIS Namespace must be defined"
  }
}

variable "rabbitmq_pvc_config" {
  type = object({
    capacity     = string
    storageClass = string
    accessModes  = list(string)
  })

  description = "Defines the configuration for RabbitMQ PVCs"

  validation {
    condition     = (endswith(var.rabbitmq_pvc_config.capacity, "Mi") || endswith(var.rabbitmq_pvc_config.capacity, "Gi")) && contains(["standard", "demis-storage-delete", "demis-storage-retain"], var.rabbitmq_pvc_config.storageClass)
    error_message = "Invalid configuration for RabbitMQ PVCs"
  }

}

variable "allow_even_rabbitmq_replicas" {
  type        = bool
  description = "Allows setting even number of RabbitMQ replicas (not recommended)"
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

variable "bulk_inbound_purger_suspend" {
  type        = bool
  description = "Defines if the bulk-inbound-purger is suspended."
  default     = false
}

variable "bulk_inbound_purger_cron_schedule" {
  type        = string
  description = "Defines the cron schedule for the bulk-inbound-purger"
  default     = "0 22 * * *"
  validation {
    condition     = length(var.bulk_inbound_purger_cron_schedule) > 0
    error_message = "The bulk-inbound-purger cron schedule must be defined"
  }
}