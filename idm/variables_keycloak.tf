variable "managed_realms" {
  type        = list(string)
  description = "List of Keycloak realms to be managed by Terraform"
  default     = []
  validation {
    condition     = alltrue([for realm in var.managed_realms : realm != ""])
    error_message = "managed_realms: Realms must not be empty strings."
  }
}