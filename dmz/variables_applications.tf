#########################
# Application Configuration
#########################

# Debugging 
variable "debug_enabled" {
  type        = bool
  description = "Defines if the backend Java Services must be started in Debug Mode"
  default     = false
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

# URL of the Secure Message Gateway
variable "secure_message_gateway_url" {
  type        = string
  description = "URL of the Secure Message Gateway"
  default     = "https://secure-message-gateway.dmz.svc.cluster.local:8080"
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