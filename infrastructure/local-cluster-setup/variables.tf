variable "kind_image_tag" {
  type        = string
  default     = "v1.27.16"
  description = "Defines the KIND Image Tag to use"

  validation {
    condition     = can(regex("v[0-9]+.[0-9]+.[0-9]+", var.kind_image_tag))
    error_message = "Error: Invalid Image Version specified"
  }
}

variable "kind_cluster_name" {
  type        = string
  description = "Defines the name of the local KIND cluster"
}

variable "kind_worker_nodes" {
  type        = number
  description = "Defines the number of KIND Worker Nodes to be created"
  default     = 2
  validation {
    condition     = var.kind_worker_nodes > 0
    error_message = "Error: Number of Worker Nodes should be greater than 0"
  }
}