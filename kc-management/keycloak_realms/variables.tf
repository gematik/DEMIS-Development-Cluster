locals {
  default_roles = ["uma_authorization", "offline_access", "default-roles-${lower(var.realm_name)}"]
}

variable "managed_realms" {
  type        = list(string)
  description = "List of Keycloak realms to be managed by Terraform"
  default     = []
  validation {
    condition     = alltrue([for realm in var.managed_realms : realm != ""])
    error_message = "managed_realms: Realms must not be empty strings."
  }
}

variable "realm_name" {
  description = "The name of the Keycloak realm"
  type        = string
}

variable "client_uuids" {
  type        = map(string)
  default     = {}
  description = "clientId => UUID for the clients that already exist in this realm, resolved by the caller at plan time."
}

variable "is_production" {
  type        = bool
  description = "Whether the environment is a production environment. Used to prevent destroying critical realms."
}