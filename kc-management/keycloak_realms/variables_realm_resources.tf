
variable "event_listener" {
  description = "List of event listeners to register in the realm"
  type        = list(string)
  default     = ["jboss-logging"]
}

variable "default_groups" {
  description = "List of default groups to register in the realm"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for group in var.default_groups :
      contains(try(var.expanded_groups_per_realm[var.realm_name], toset([])), group)
    ])
    error_message = "(Realm: ${var.realm_name}) Invalid default group(s) specified: '${join(", ", [for group in var.default_groups : group if !contains(try(var.expanded_groups_per_realm[var.realm_name], toset([])), group)])}'. Allowed values are active groups in expanded_groups_per_realm for realm ${var.realm_name}: '${join(", ", sort(tolist(try(var.expanded_groups_per_realm[var.realm_name], toset([])))))}'"
  }
}


variable "clients" {
  description = "List of clients in the realm"
  type = list(map(object({
    mappers               = optional(list(string), []),
    roles                 = optional(list(string), []),
    service_account_roles = optional(list(string), []) # only client roles allowed; realm roles are not implemented
  })))
  default = []

  validation {
    condition     = alltrue([for client in var.clients : contains(keys(var.openid_clients), keys(client)[0])])
    error_message = "(Realm: ${var.realm_name}) Invalid client(s) specified: '${join(", ", [for client in var.clients : keys(client)[0] if !contains(keys(var.openid_clients), keys(client)[0])])}'. Allowed values are: '${join(", ", keys(var.openid_clients))}'"
  }

  validation {
    condition = alltrue([
      for client in var.clients : alltrue([
        for mapper in client[keys(client)[0]].mappers :
        contains(keys(var.client_mapper_configs), mapper)
      ])
    ])

    error_message = "(Realm: ${var.realm_name}) Invalid mapper(s) specified: '${join("; ", [
      for client in var.clients :
      format(
        "%s: [%s]",
        keys(client)[0],
        join(", ", [
          for mapper in client[keys(client)[0]].mappers :
          mapper if !contains(keys(var.client_mapper_configs), mapper)
        ])
      )
      if !alltrue([
        for mapper in client[keys(client)[0]].mappers :
        contains(keys(var.client_mapper_configs), mapper)
      ])
    ])}'. Allowed values are: '${join(", ", keys(var.client_mapper_configs))}'"
  }
}

variable "disabled_clients" {
  description = "List of disabled clients in the realm"
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for client in var.disabled_clients : contains(keys(var.openid_clients), client)])
    error_message = "(Realm: ${var.realm_name}) Invalid disabled client(s) specified: '${join(", ", [for client in var.disabled_clients : client if !contains(keys(var.openid_clients), client)])}'. Allowed values are: '${join(", ", keys(var.openid_clients))}'"
  }
}

variable "idps" {
  description = "List of identity providers in the realm"
  type        = list(map(list(string)))
  default     = []
  validation {
    condition     = alltrue([for idp in var.idps : contains(keys(var.idp_configs[var.realm_name]), keys(idp)[0])])
    error_message = "(Realm: ${var.realm_name}) Invalid identity provider(s) specified: '${join(", ", [for idp in var.idps : keys(idp)[0] if !contains(keys(var.idp_configs[var.realm_name]), keys(idp)[0])])}'. Allowed values are: '${join(", ", keys(var.idp_configs[var.realm_name]))}'"
  }
}
variable "roles" {
  description = "List of roles in the realm"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for role in var.roles : contains(keys(var.roles_config), role)])
    error_message = "(Realm: ${var.realm_name}) Invalid role(s) specified: '${join(", ", [for role in var.roles : role if !contains(keys(var.roles_config), role)])}'. Allowed values are: '${join(", ", keys(var.roles_config))}'"
  }

  validation {
    condition     = alltrue([for default_role in local.default_roles : !contains(var.roles, default_role)])
    error_message = "(Realm: ${var.realm_name}) Do not specify default roles in the 'roles' variable. Found: '${join("', '", [for default_role in local.default_roles : default_role if contains(var.roles, default_role)])}'. The following default roles are automatically created in every realm: '${join("', '", local.default_roles)}'"
  }
}

variable "users" {
  description = "A map of user lists for different realms"
  type = list(object({
    id            = optional(string)
    username      = string
    email         = string
    emailVerified = bool
    firstName     = string
    lastName      = string
    enabled       = bool
    groups        = list(string)
    realmRoles    = list(string)
    clientRoles   = optional(map(list(string)), {})
    attributes    = map(string)
    password      = bool
    federatedIdentities = list(object({
      identityProvider = string
      userId           = string
      userName         = string
    }))
  }))

  validation {
    condition = alltrue([
      for user in var.users : length([
        for group in user.groups : group
        if !contains(try(var.expanded_groups_per_realm[var.realm_name], toset([])), group)
      ]) == 0
    ])
    error_message = "(Realm: ${var.realm_name}) User have group(s) that are not defined in the group hierarchy. Invalid groups by user: '${join("; ", [for user in var.users : format("%s: [%s]", user.username, join(", ", [for group in user.groups : group if !contains(try(var.expanded_groups_per_realm[var.realm_name], toset([])), group)])) if length([for group in user.groups : group if !contains(try(var.expanded_groups_per_realm[var.realm_name], toset([])), group)]) > 0])}'. Groups active in realm ${var.realm_name}: '${join(", ", sort(tolist(try(var.expanded_groups_per_realm[var.realm_name], toset([])))))}'"
  }
}

variable "auth_flows" {
  description = "List of authentication flows to create in the realm"
  type        = list(string)

  validation {
    condition     = alltrue([for flow in var.auth_flows : contains(keys(var.auth_flow_configs), flow)])
    error_message = "(Realm: ${var.realm_name}) Invalid auth flow(s) specified: '${join(", ", [for flow in var.auth_flows : flow if !contains(keys(var.auth_flow_configs), flow)])}'. Allowed values are: '${join(", ", keys(var.auth_flow_configs))}'"
  }
}

variable "expanded_groups_per_realm" {
  description = "A map of expanded group sets per realm, including all groups and their ancestors"
  type        = map(set(string))

  validation {
    condition = alltrue([
      for group in try(var.expanded_groups_per_realm[var.realm_name], toset([])) :
      contains(keys(var.keycloak_root_groups), group) ||
      contains(keys(var.keycloak_level1_groups), group) ||
      contains(keys(var.keycloak_level2_groups), group)
    ])
    error_message = "(Realm: ${var.realm_name}) Invalid group(s) in expanded_groups_per_realm: '${join(", ", [
      for group in try(var.expanded_groups_per_realm[var.realm_name], toset([])) : group
      if !(contains(keys(var.keycloak_root_groups), group) || contains(keys(var.keycloak_level1_groups), group) || contains(keys(var.keycloak_level2_groups), group))
    ])}'. Allowed values are: '${join(", ", concat(keys(var.keycloak_root_groups), keys(var.keycloak_level1_groups), keys(var.keycloak_level2_groups)))}'"
  }
}


