variable "roles_config" {
  type        = any
  description = "Realm and client role definitions, keyed by role name."
}

variable "openid_clients" {
  type        = any
  description = "Configuration for the OpenID clients in the realm"
}

variable "idp_configs" {
  type        = any
  description = "Identity provider definitions, keyed by IdP alias."
}

variable "auth_flow_configs" {
  type        = any
  description = "Authentication flow definitions with their executions, keyed by flow alias."
}

variable "idp_mapper_configs" {
  type        = any
  description = "Identity provider mapper definitions, keyed by mapper name."
}

variable "client_mapper_configs" {
  type        = any
  description = "Protocol mapper definitions available to clients, keyed by mapper name."
}

variable "keycloak_root_groups" {
  description = "A map of Keycloak root groups (groups without parent)"
  type = map(object({
    name  = string
    roles = optional(list(string), [])
    client_roles = optional(list(object({
      client = string
      name   = string
    })), [])
    attributes = optional(map(string), {})
  }))
  default = {}
}

variable "keycloak_level1_groups" {
  description = "A map of Keycloak level 1 groups (groups with root group as parent)"
  type = map(object({
    name   = string
    parent = string
    roles  = optional(list(string), [])
    client_roles = optional(list(object({
      client = string
      name   = string
    })), [])
    attributes = optional(map(string), {})
  }))
  default = {}
  validation {
    condition     = alltrue([for group in var.keycloak_level1_groups : contains(keys(var.keycloak_root_groups), group.parent)])
    error_message = "(Realm: ${var.realm_name}) Invalid parent group(s) specified for level 1 groups: '${join(", ", [for group in var.keycloak_level1_groups : group.parent if !contains(keys(var.keycloak_root_groups), group.parent)])}'. Allowed values are: '${join(", ", keys(var.keycloak_root_groups))}'"
  }
}

variable "keycloak_level2_groups" {
  description = "A map of Keycloak level 2 groups (groups with level 1 group as parent)"
  type = map(object({
    name   = string
    parent = string
    roles  = optional(list(string), [])
    client_roles = optional(list(object({
      client = string
      name   = string
    })), [])
    attributes = optional(map(string), {})
  }))
  default = {}
  validation {
    condition     = alltrue([for group in var.keycloak_level2_groups : contains(keys(var.keycloak_level1_groups), group.parent)])
    error_message = "(Realm: ${var.realm_name}) Invalid parent group(s) specified for level 2 groups: '${join(", ", [for group in var.keycloak_level2_groups : group.parent if !contains(keys(var.keycloak_level1_groups), group.parent)])}'. Allowed values are: '${join(", ", keys(var.keycloak_level1_groups))}'"
  }
}
