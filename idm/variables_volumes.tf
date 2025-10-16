#########################
# Volumes
#########################

variable "volumes" {
  type = map(object({
    storage_class = string
    capacity      = string
  }))

  description = "Defines the volumes to be used for the Identity Management services"

  validation {
    condition     = alltrue([for k, v in var.volumes : endswith(v.capacity, "Mi") || endswith(v.capacity, "Gi")]) && alltrue([for k, v in var.volumes : contains(["standard", "demis-storage-delete", "demis-storage-retain"], v.storage_class)])
    error_message = "Invalid configuration for volumes"
  }
}
