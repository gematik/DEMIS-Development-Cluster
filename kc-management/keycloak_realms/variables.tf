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

variable "keycloak_connection_url" {
  type        = string
  description = "Base URL of the Keycloak instance, used for plan-time client existence checks."
}

variable "keycloak_admin_token" {
  type        = string
  sensitive   = true
  description = "Admin access token used for plan-time client existence checks against the Keycloak admin API."
}

variable "insecure_connection" {
  type        = bool
  default     = false
  description = "Whether to skip TLS verification for plan-time client existence checks."
}

variable "keycloak_themes" {
  type        = map(string)
  description = "Themes to be used for the Keycloak realm (login, account, admin, email)."
}
