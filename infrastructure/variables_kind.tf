#########################
# Local Cluster Settings
#########################

variable "local_cluster" {
  type        = bool
  default     = true
  description = "Defines if the current setup is for a local cluster (using KIND)"
}

variable "kind_image_tag" {
  type        = string
  default     = "v1.32.2"
  description = "Defines the KIND Image Tag to use."
}

variable "kind_cluster_name" {
  type        = string
  default     = ""
  description = "Defines the name of the local KIND cluster"
}

variable "kind_worker_nodes" {
  type        = number
  description = "Defines the number of KIND Worker Nodes to be created"
  default     = 2
  validation {
    condition     = var.kind_worker_nodes > 0
    error_message = "Error: Number of KIND Worker Nodes should be greater than 0"
  }
}

variable "kind_service_subnet_address" {
  type        = string
  default     = "10.0.26.0/16"
  description = "Defines the service subnet address for the KIND cluster"
  validation {
    condition     = can(cidrnetmask(var.kind_service_subnet_address))
    error_message = "Error: Invalid CIDR notation for service subnet address"
  }
}
