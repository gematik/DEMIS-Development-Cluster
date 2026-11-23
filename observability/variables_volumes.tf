#########################
# Volumes
#########################

variable "volumes" {
  type = map(object({
    storage_class = string
    capacity      = string
  }))

  description = "Defines the volumes of the observability namespace: postgres-volume-claim (postgres), object-storage-volume-claim (object-storage-service). The Loki volumes come from its StatefulSet (loki_volume)."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.volumes : endswith(v.capacity, "Mi") || endswith(v.capacity, "Gi")]) && alltrue([for k, v in var.volumes : contains(["standard", "demis-storage-delete", "demis-storage-retain"], v.storage_class)])
    error_message = "Invalid configuration for volumes"
  }
}
