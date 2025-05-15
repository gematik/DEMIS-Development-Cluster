variable "namespace" {
  type        = string
  description = "The name of the Namespace where the Persistence Volume Claim will be created"
  validation {
    condition     = length(var.namespace) > 0
    error_message = "You must provide a valid name for the Namespace."
  }
}

variable "labels" {
  type        = map(string)
  description = "The Labels to apply to the Persistence Volume Claim"
  default     = {}
}

variable "annotations" {
  type        = map(string)
  description = "The Annotations to apply to the Persistence Volume Claim"
  default     = {}
}

variable "name" {
  type        = string
  description = "The Name of the Pull Secret"
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 30
    error_message = "You must provide a valid Name for the Persistence Volume Claim."
  }
}

variable "storage_class" {
  type        = string
  description = "The Storage Class to use for the Persistence Volume Claim"
  validation {
    condition     = contains(["standard", "demis-storage-delete", "demis-storage-retain"], var.storage_class)
    error_message = "You must provide a valid Storage Class for the Persistence Volume Claim."
  }
}

variable "capacity" {
  type        = string
  description = "The Capacity of the Persistence Volume Claim"
  validation {
    condition     = endswith(var.capacity, "Mi") || endswith(var.capacity, "Gi")
    error_message = "You must provide a valid Capacity for the Persistence Volume Claim."
  }
}

variable "access_mode" {
  type        = string
  description = "The Access Mode of the Persistence Volume Claim"
  validation {
    condition     = contains(["ReadWriteOnce", "ReadOnlyMany", "ReadWriteMany", "ReadWriteOncePod"], var.access_mode)
    error_message = "You must provide a valid Access Mode for the Persistence Volume Claim."
  }
}

variable "wait_until_bound" {
  type        = bool
  description = "Wait until the Persistence Volume Claim is bound by some Pod. Default is false."
  default     = false
}
