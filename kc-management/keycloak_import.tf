locals {
  keycloak_import_token = try(jsondecode(data.http.keycloak_import_admin_token[0].response_body).access_token, "")
  # Filtered list of realm to import based on the provided variable.
  realms_to_import = [
    for realm in keys(local.keycloak_realms) : realm
    if contains(var.realms_to_import, realm)
  ]
}

data "http" "keycloak_import_admin_token" {
  count = length(local.realms_to_import) > 0 ? 1 : 0

  url      = "${var.stage_specific_keycloak_config.provider_connection_url}/realms/master/protocol/openid-connect/token"
  method   = "POST"
  insecure = local.insecure_connection

  request_headers = {
    Content-Type = "application/x-www-form-urlencoded"
  }

  request_body = "grant_type=client_credentials&client_id=terraform-client&client_secret=${urlencode(var.keycloak_terraform_client_secret)}"

  retry {
    attempts     = 10
    max_delay_ms = 5000
    min_delay_ms = 1000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200 && try(jsondecode(self.response_body).access_token, "") != ""
      error_message = "Failed to obtain Keycloak admin token. A running and reachable Keycloak instance is required for the import process."
    }
  }

}

# ============================================================================
# === Import existing realms =================================================
# ============================================================================
import {
  for_each = toset([for realm in local.realms_to_import : realm if realm != "master"])
  to       = module.realms[each.key].keycloak_realm.realm
  id       = each.value
}

# Import master realm only if it already exists.
import {
  for_each = contains(keys(local.keycloak_realms), "master") ? toset(["master"]) : toset([])
  to       = module.realms["master"].keycloak_realm.realm
  id       = "master"
}

# ============================================================================
# === Import existing realm certs ============================================
# ============================================================================
data "keycloak_realm_keys" "certs" {
  for_each = { for realm in local.realms_to_import : realm => realm }
  realm_id = each.value
}

locals {
  # One entry per configured cert; adopt a single existing active RSA key provider
  # of the cert's algorithm (a realm may expose several active keys with the same kid).
  import_certs = {
    for item in flatten([
      for realm in local.realms_to_import : [
        for cert in nonsensitive(try(var.keycloak_certs[realm], [])) : merge(
          cert,
          {
            realm = realm
            provider_id = try([
              for key in data.keycloak_realm_keys.certs[realm].keys : key.provider_id
              if key.type == "RSA" && key.status == "ACTIVE" && key.algorithm == cert.algorithm
            ][0], null)
          }
        )
      ]
    ]) : "${item.realm}/${item.name}" => item
    if item.provider_id != null
  }
}

import {
  for_each = local.import_certs
  to       = module.realms[each.value.realm].keycloak_realm_keystore_rsa.certs[each.value.name]
  id       = "${each.value.realm}/${each.value.provider_id}"
}

# ============================================================================
# === Import existing users ==================================================
# ============================================================================
locals {
  users_to_import_default = flatten([
    for realm in try(local.realms_to_import, []) : [
      for user in try(local.users[realm], []) : {
        realm = realm
        user  = user
      } if user.id != null && realm != "SURVEILLANCE-PROGRAMS"
    ]
  ])

  users_to_import_surveillance = flatten([
    for realm in try(local.realms_to_import, []) : [
      for user in try(local.users[realm], []) : {
        realm = realm
        user  = user
      } if user.id != null && realm == "SURVEILLANCE-PROGRAMS"
    ]
  ])
  existing_users_to_import_default = {
    for key, item in { for i in local.users_to_import_default : "${i.realm}/${i.user.username}" => i } :
    key => item if try(data.http.user_to_import_exists[key].status_code, 404) == 200
  }

  existing_users_to_import_surveillance = {
    for key, item in { for i in local.users_to_import_surveillance : "${i.realm}/${i.user.username}" => i } :
    key => item if try(data.http.user_to_import_exists[key].status_code, 404) == 200
  }
}

# Guard against a provider panic (nil deref in resourceKeycloakUserImport) when a
# configured user id no longer exists in Keycloak: only import users that return HTTP 200.
data "http" "user_to_import_exists" {
  for_each = merge(
    { for item in local.users_to_import_default : "${item.realm}/${item.user.username}" => item },
    { for item in local.users_to_import_surveillance : "${item.realm}/${item.user.username}" => item },
  )

  url      = "${var.stage_specific_keycloak_config.provider_connection_url}/admin/realms/${each.value.realm}/users/${each.value.user.id}"
  method   = "GET"
  insecure = local.insecure_connection

  request_headers = {
    Authorization = "Bearer ${local.keycloak_import_token}"
  }
}

import {
  for_each = local.existing_users_to_import_default
  to       = module.realms[each.value.realm].keycloak_user.user[each.value.user.username]
  id       = "${each.value.realm}/${each.value.user.id}"
}

import {
  for_each = local.existing_users_to_import_surveillance
  to       = module.realms[each.value.realm].keycloak_user.users_surveillance_programs[each.value.user.username]
  id       = "${each.value.realm}/${each.value.user.id}"
}


# ============================================================================
# === Import existing groups =================================================
# ============================================================================
# Look up existing groups through the Admin API so missing groups can be created.
data "http" "realm_groups" {
  for_each = toset(local.realms_to_import)

  url      = "${var.stage_specific_keycloak_config.provider_connection_url}/admin/realms/${each.value}/groups?q=*"
  method   = "GET"
  insecure = local.insecure_connection

  request_headers = {
    Authorization = "Bearer ${local.keycloak_import_token}"
    Content-Type  = "application/json"
  }

  retry {
    attempts     = 10
    max_delay_ms = 5000
    min_delay_ms = 1000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200 && try(jsondecode(self.response_body), false) != false
      error_message = "Failed to fetch groups for realm: '${each.value}'"
    }
  }
}

locals {
  # Terraform has no recursion; the group catalogue has at most three levels, so each level is merged explicitly.
  keycloak_group_tree = {
    for realm, response in data.http.realm_groups : realm => flatten([
      for root in try(jsondecode(response.response_body), []) : concat(
        [{ path = root.path, id = root.id }],
        flatten([
          for level1 in try(root.subGroups, []) : concat(
            [{ path = level1.path, id = level1.id }],
            [
              for level2 in try(level1.subGroups, []) : { path = level2.path, id = level2.id }
            ]
          )
        ])
      )
    ])
  }

  existing_groups = {
    root = {
      for item in flatten([
        for realm in local.realms_to_import : [
          for group_key, group in local.group_catalogues.root : {
            key   = "${realm}/${group_key}"
            path  = "/${group.name}"
            realm = realm
          } if contains(local.expanded_groups_per_realm[realm], group_key)
        ]
        ]) : item.key => {
        id = [for group in local.keycloak_group_tree[item.realm] : group.id if group.path == item.path][0]
      } if contains([for group in local.keycloak_group_tree[item.realm] : group.path], item.path)
    }
    level1 = {
      for item in flatten([
        for realm in local.realms_to_import : [
          for group_key, group in local.group_catalogues.level1 : {
            key   = "${realm}/${group_key}"
            path  = "/${local.group_catalogues.root[group.parent].name}/${group.name}"
            realm = realm
          } if contains(local.expanded_groups_per_realm[realm], group_key)
        ]
        ]) : item.key => {
        id = [for group in local.keycloak_group_tree[item.realm] : group.id if group.path == item.path][0]
      } if contains([for group in local.keycloak_group_tree[item.realm] : group.path], item.path)
    }
    level2 = {
      for item in flatten([
        for realm in local.realms_to_import : [
          for group_key, group in local.group_catalogues.level2 : {
            key   = "${realm}/${group_key}"
            path  = "/${local.group_catalogues.root[local.group_catalogues.level1[group.parent].parent].name}/${local.group_catalogues.level1[group.parent].name}/${group.name}"
            realm = realm
          } if contains(local.expanded_groups_per_realm[realm], group_key)
        ]
        ]) : item.key => {
        id = [for group in local.keycloak_group_tree[item.realm] : group.id if group.path == item.path][0]
      } if contains([for group in local.keycloak_group_tree[item.realm] : group.path], item.path)
    }
  }
}

# Import only groups that already exist; the remaining resources are created.
import {
  for_each = local.existing_groups.root
  to       = module.realms[split("/", each.key)[0]].keycloak_group.root[split("/", each.key)[1]]
  id       = "${split("/", each.key)[0]}/${each.value.id}"
}

import {
  for_each = local.existing_groups.level1
  to       = module.realms[split("/", each.key)[0]].keycloak_group.level1[split("/", each.key)[1]]
  id       = "${split("/", each.key)[0]}/${each.value.id}"
}

import {
  for_each = local.existing_groups.level2
  to       = module.realms[split("/", each.key)[0]].keycloak_group.level2[split("/", each.key)[1]]
  id       = "${split("/", each.key)[0]}/${each.value.id}"
}

# ============================================================================
# === Import existing clients ================================================
# ============================================================================
locals {
  clients_to_import = {
    for item in flatten([
      for realm in local.realms_to_import : flatten([
        for clients_map in try(local.keycloak_realms[realm].clients, []) : [
          for client_name, _ in clients_map : {
            key       = "${realm}/${client_name}"
            realm     = realm
            client_id = client_name
          }
        ]
      ])
      ]) : item.key => {
      realm     = item.realm
      client_id = item.client_id
    }
  }

  default_clients_to_lookup = merge([
    for realm in local.realms_to_import : {
      for client_name, client_config in local.openid_clients[realm] :
      "${realm}/${client_name}" => {
        realm     = realm
        client_id = client_name
      }
      if try(client_config[realm].defaultClient, client_config.defaultClient, false)
    }
  ]...)

  clients_to_lookup = merge(local.clients_to_import, local.default_clients_to_lookup)

  # Clients from the catalogue may not exist in Keycloak yet; those must not fail the plan.
  existing_client_keys = toset([
    for key, item in local.clients_to_lookup : key
    if contains([for c in jsondecode(data.http.realm_clients[item.realm].response_body) : c.clientId], item.client_id)
  ])
}

data "http" "realm_clients" {
  for_each = toset(local.realms_to_import)

  url      = "${var.stage_specific_keycloak_config.provider_connection_url}/admin/realms/${each.value}/clients"
  method   = "GET"
  insecure = local.insecure_connection

  request_headers = {
    Authorization = "Bearer ${local.keycloak_import_token}"
    Content-Type  = "application/json"
  }

  retry {
    attempts     = 10
    max_delay_ms = 5000
    min_delay_ms = 1000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200 && try(jsondecode(self.response_body), false) != false
      error_message = "Fail to fetch clients for realm: '${each.value}'"
    }
  }
}

data "keycloak_openid_client" "clients" {
  for_each = {
    for key, item in local.clients_to_lookup : key => item
    if contains(local.existing_client_keys, key)
  }

  realm_id  = each.value.realm
  client_id = each.value.client_id
}

import {
  for_each = {
    for key, item in local.clients_to_import : key => item
    if contains(local.existing_client_keys, key)
  }
  to = module.realms[each.value.realm].keycloak_openid_client.clients[each.value.client_id]
  id = "${each.value.realm}/${data.keycloak_openid_client.clients[each.key].id}"
}

# ============================================================================
# === Import existing clientmappers ==========================================
# ============================================================================
locals {
  client_mapper_to_import = merge({}, [
    for realm in local.realms_to_import : merge({}, [
      for clients_map in try(local.keycloak_realms[realm].clients, []) : merge({}, [
        for client_name, client_cfg in clients_map : merge({}, [
          for effective_client in distinct(concat([client_name], try(client_cfg.clients, []))) : {
            for mapper in try(client_cfg.mappers, []) :
            "${realm}/${effective_client}/${mapper}" => {
              realm       = realm
              client      = effective_client
              mapper_name = mapper
            }
          }
        ]...)
      ]...)
    ]...)
  ]...)

  existing_client_mapper_ids = {
    for key, item in local.client_mapper_to_import : key => one(flatten([
      for client in jsondecode(data.http.realm_clients[item.realm].response_body) : [
        for mapper in try(client.protocolMappers, []) : mapper.id
        if client.clientId == item.client && mapper.name == item.mapper_name
      ]
    ]))
    if length(flatten([
      for client in jsondecode(data.http.realm_clients[item.realm].response_body) : [
        for mapper in try(client.protocolMappers, []) : mapper.id
        if client.clientId == item.client && mapper.name == item.mapper_name
      ]
    ])) > 0
  }
}

import {
  for_each = {
    for key, item in local.client_mapper_to_import : key => item
    if contains(keys(local.existing_client_mapper_ids), key)
  }
  to = module.realms[each.value.realm].keycloak_generic_protocol_mapper.protocol_mappers["${each.value.client}-${each.value.mapper_name}"]
  id = "${each.value.realm}/client/${data.keycloak_openid_client.clients["${each.value.realm}/${each.value.client}"].id}/${local.existing_client_mapper_ids[each.key]}"
}

# ============================================================================
# === Import existing realm roles ============================================
# ============================================================================
locals {
  roles_to_import = {
    for item in flatten([
      for realm in local.realms_to_import : [
        for role in try(local.keycloak_realms[realm].roles, []) : {
          key   = "${realm}/${role}"
          realm = realm
          role  = role
        }
      ]
      ]) : item.key => {
      realm = item.realm
      role  = item.role
    }
  }

  existing_roles_to_import = {
    for key, item in local.roles_to_import : key => merge(item, {
      id = [
        for role in jsondecode(data.http.realm_roles[item.realm].response_body) : role.id
        if role.name == item.role
      ][0]
    })
    if contains(
      [for role in jsondecode(data.http.realm_roles[item.realm].response_body) : role.name],
      item.role
    )
  }
}

data "http" "realm_roles" {
  for_each = toset(local.realms_to_import)

  url      = "${var.stage_specific_keycloak_config.provider_connection_url}/admin/realms/${each.value}/roles"
  method   = "GET"
  insecure = local.insecure_connection

  request_headers = {
    Authorization = "Bearer ${local.keycloak_import_token}"
    Content-Type  = "application/json"
  }

  retry {
    attempts     = 10
    max_delay_ms = 5000
    min_delay_ms = 1000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200 && try(jsondecode(self.response_body), false) != false
      error_message = "Failed to fetch roles for realm: '${each.value}'"
    }
  }
}

import {
  for_each = local.existing_roles_to_import
  to       = module.realms[each.value.realm].keycloak_role.roles[each.value.role]
  id       = "${each.value.realm}/${each.value.id}"
}

# ============================================================================
# === Import existing client roles ===========================================
# ============================================================================
locals {
  client_roles_to_import = {
    for item in flatten([
      for realm in local.realms_to_import : flatten([
        for clients_map in try(local.keycloak_realms[realm].clients, []) : [
          for client_name, client_cfg in clients_map : [
            for role in try(client_cfg.roles, []) : {
              key         = "${realm}/${client_name}/${role}"
              realm       = realm
              client_name = client_name
              role        = role
            }
          ]
        ]
      ])
      ]) : item.key => {
      realm       = item.realm
      client_name = item.client_name
      role        = item.role
    }
  }
}

data "keycloak_role" "client_roles" {
  for_each  = local.client_roles_to_import
  realm_id  = each.value.realm
  client_id = data.keycloak_openid_client.clients["${each.value.realm}/${each.value.client_name}"].id
  name      = each.value.role
}

import {
  for_each = local.client_roles_to_import
  to       = module.realms[each.value.realm].keycloak_role.client_roles["${each.value.client_name}-${each.value.role}"]
  id       = "${each.value.realm}/${data.keycloak_role.client_roles[each.key].id}"
}

# ============================================================================
# === Import existing identity providers =====================================
# ============================================================================
locals {
  idps_to_import = {
    for item in flatten([
      for realm in local.realms_to_import : [
        for idps_map in try(local.keycloak_realms[realm].idps, []) : [
          for idp_name, _ in idps_map : {
            key   = "${realm}/${idp_name}"
            realm = realm
            idp   = idp_name
          }
        ]
      ]
      ]) : item.key => {
      realm = item.realm
      idp   = item.idp
    }
  }
  idp_type_by_alias = {
    "gematik-idp"           = "oidc"
    "entra-id"              = "oidc"
    "bundid-idp"            = "saml"
    "muk"                   = "saml"
    "gematik-authenticator" = "oidc"
  }

  oidc_idps_to_import = {
    for key, item in local.idps_to_import : key => item
    if try(local.idp_type_by_alias[item.idp], "") == "oidc" && (item.idp != "entra-id" || !var.local_cluster)
    && contains(local.existing_idp_keys, key)
  }

  saml_idps_to_import = {
    for key, item in local.idps_to_import : key => item
    if try(local.idp_type_by_alias[item.idp], "") == "saml"
    && contains(local.existing_idp_keys, key)
  }

  # The mappers endpoint answers 404 if the identity provider does not exist yet.
  existing_idp_keys = [
    for key, response in data.http.idp_mappers : key
    if response.status_code == 200
  ]

}

import {
  for_each = local.oidc_idps_to_import
  to       = module.realms[each.value.realm].keycloak_oidc_identity_provider.oidc_idps[each.value.idp]
  id       = each.key
}
import {
  for_each = local.saml_idps_to_import
  to       = module.realms[each.value.realm].keycloak_saml_identity_provider.saml_idps[each.value.idp]
  id       = each.key
}

# ============================================================================
# === Import existing identity provider mappers ==============================
# ============================================================================

locals {
  idp_mapper_to_import = {
    for item in flatten([
      for realm in local.realms_to_import : [
        for idps_map in try(local.keycloak_realms[realm].idps, []) : [
          for idp_name, mapper_list in idps_map : [
            for mapper in mapper_list : {
              key = "${realm}/${idp_name}/${mapper}"
              value = {
                realm       = realm
                idp         = idp_name
                mapper_name = mapper
              }
            } if !var.local_cluster || idp_name != "entra-id"
          ]
        ]
      ]
    ]) : item.key => item.value
  }

  # Mappers per identity provider; empty if the provider does not exist yet.
  idp_mappers_by_idp = {
    for key, response in data.http.idp_mappers :
    key => jsondecode(response.status_code == 200 ? response.response_body : "[]")
  }

  # Import only mappers that already exist in Keycloak.
  idp_mapper_ids_to_import = {
    for key, item in local.idp_mapper_to_import : key => [
      for mapper in try(local.idp_mappers_by_idp["${item.realm}/${item.idp}"], []) : mapper.id
      if mapper.name == item.mapper_name
    ]
  }

  existing_idp_mapper_ids = {
    for key, ids in local.idp_mapper_ids_to_import : key => one(ids)
    if length(ids) > 0
  }
}

data "http" "idp_mappers" {
  for_each = { for key, item in local.idps_to_import : key => item if(!var.local_cluster || item.idp != "entra-id") }
  url      = "${var.stage_specific_keycloak_config.provider_connection_url}/admin/realms/${each.value.realm}/identity-provider/instances/${each.value.idp}/mappers"
  method   = "GET"
  insecure = local.insecure_connection
  request_headers = {
    Authorization = "Bearer ${local.keycloak_import_token}"
    Content-Type  = "application/json"
  }

  retry {
    attempts     = 10
    max_delay_ms = 5000
    min_delay_ms = 1000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 404 || (self.status_code == 200 && try(jsondecode(self.response_body), false) != false)
      error_message = "Fail to fetch idp_mapper for realm: '${each.value.realm}' and idp: '${each.value.idp}'"
    }
  }

}

import {
  for_each = {
    for key, item in local.idp_mapper_to_import : key => item
    if contains(keys(local.existing_idp_mapper_ids), key)
  }
  to = module.realms[each.value.realm].keycloak_custom_identity_provider_mapper.idp_mappers["${each.value.idp}-${each.value.mapper_name}"]
  id = "${each.value.realm}/${each.value.idp}/${local.existing_idp_mapper_ids[each.key]}"
}

# ============================================================================
# === Import existing authentication flows ===================================
# ============================================================================

locals {
  auth_flows = {
    for item in flatten([
      for realm in local.realms_to_import : [
        for flow in try(local.keycloak_realms[realm].auth_flows, []) : {
          key   = "${realm}/${flow}"
          realm = realm
          flow  = flow
        }
      ]
      ]) : item.key => {
      realm = item.realm
      flow  = item.flow
    }
  }
}

data "keycloak_authentication_flow" "flows" {
  for_each = local.auth_flows
  realm_id = each.value.realm
  alias    = each.value.flow
}

import {
  for_each = local.auth_flows
  to       = module.realms[each.value.realm].keycloak_authentication_flow.flows[each.value.flow]
  id       = "${each.value.realm}/${data.keycloak_authentication_flow.flows[each.key].id}"
}

# Import existing authentication flow executions and their configurations

locals {
  flow_executions_to_import = {
    for item in flatten([
      for flow_key, flow_data in data.http.flow_executions : [
        for execution in jsondecode(flow_data.response_body) : {
          key = "${flow_key}/${execution.id}"
          value = {
            realm          = split("/", flow_key)[0]
            flow           = split("/", flow_key)[1]
            execution_id   = execution.id
            auth_config_id = try(execution.authenticationConfig, null)
            provider_id    = execution.providerId
          }
        }
      ]
    ]) : item.key => item.value
  }

  # Group all execution candidates by realm+flow+provider_id.
  flow_execution_candidates_by_provider = {
    for item in values(local.flow_executions_to_import) :
    "${item.realm}/${item.flow}/${item.provider_id}" => item...
  }

  # The module creates one execution per flow+provider_id key.
  # Prefer the candidate with auth_config_id when present.
  flow_executions_by_provider_to_import = {
    for import_key, candidates in local.flow_execution_candidates_by_provider :
    import_key => try(
      [for candidate in candidates : candidate if candidate.auth_config_id != null][0],
      candidates[0]
    )
  }

  flow_execution_configs_to_import = {
    for key, item in local.flow_executions_by_provider_to_import : key => item
    if item.auth_config_id != null
  }
}

data "http" "flow_executions" {
  for_each = local.auth_flows
  url      = "${var.stage_specific_keycloak_config.provider_connection_url}/admin/realms/${each.value.realm}/authentication/flows/${each.value.flow}/executions"
  method   = "GET"
  insecure = local.insecure_connection
  request_headers = {
    Authorization = "Bearer ${local.keycloak_import_token}"
    Content-Type  = "application/json"
  }

  retry {
    attempts     = 10
    max_delay_ms = 5000
    min_delay_ms = 1000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200 && try(jsondecode(self.response_body), false) != false
      error_message = "Fail to fetch executions"
    }
  }
}

import {
  for_each = local.flow_executions_by_provider_to_import
  to       = module.realms[each.value.realm].keycloak_authentication_execution.executions["${each.value.flow}-${each.value.provider_id}"]
  id       = "${each.value.realm}/${each.value.flow}/${each.value.execution_id}"
}

import {
  for_each = local.flow_execution_configs_to_import
  to       = module.realms[each.value.realm].keycloak_authentication_execution_config.execution_configs["${each.value.flow}-${each.value.provider_id}"]
  id       = "${each.value.realm}/${each.value.execution_id}/${each.value.auth_config_id}"
}

# ============================================================================
# === Import Token-Exchange Resources INSTITUTIONS-TI ========================
# ============================================================================

locals {
  import_policy           = contains(local.realms_to_import, "INSTITUTIONS-TI") && contains([for idp in local.keycloak_realms["INSTITUTIONS-TI"].idps : keys(idp)[0]], "gematik-idp")
  gematik_idp_resource_id = try(jsondecode(data.http.gematik_idp_authz_resource[0].response_body)[0]._id, null)
  permission_id           = try(jsondecode(data.http.token_exchange_permissions[0].response_body)[0].id, null)
}

data "keycloak_openid_client" "institutions_ti_realm_management" {
  count     = local.import_policy ? 1 : 0
  realm_id  = "INSTITUTIONS-TI"
  client_id = "realm-management"
}

data "keycloak_openid_client_authorization_scope" "token_exchange_scope" {
  count              = local.import_policy ? 1 : 0
  realm_id           = "INSTITUTIONS-TI"
  resource_server_id = data.keycloak_openid_client.institutions_ti_realm_management[0].resource_server_id
  name               = "token-exchange"
}

data "keycloak_openid_client_authorization_policy" "token_exchange_policy" {
  count              = local.import_policy ? 1 : 0
  realm_id           = "INSTITUTIONS-TI"
  resource_server_id = data.keycloak_openid_client.institutions_ti_realm_management[0].resource_server_id
  name               = "token-exchange-client-policy"
}

data "http" "gematik_idp_authz_resource" {
  count    = local.import_policy ? 1 : 0
  url      = "${var.stage_specific_keycloak_config.provider_connection_url}/admin/realms/INSTITUTIONS-TI/clients/${data.keycloak_openid_client.institutions_ti_realm_management[0].id}/authz/resource-server/resource?type=IdentityProvider"
  method   = "GET"
  insecure = local.insecure_connection
  request_headers = {
    Authorization = "Bearer ${local.keycloak_import_token}"
    Content-Type  = "application/json"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Failed to fetch gematik-idp authorization resource"
    }
  }
}

data "http" "token_exchange_permissions" {
  count    = local.import_policy ? 1 : 0
  url      = "${var.stage_specific_keycloak_config.provider_connection_url}/admin/realms/INSTITUTIONS-TI/clients/${data.keycloak_openid_client.institutions_ti_realm_management[0].id}/authz/resource-server/permission"
  method   = "GET"
  insecure = local.insecure_connection
  request_headers = {
    Authorization = "Bearer ${local.keycloak_import_token}"
    Content-Type  = "application/json"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Failed to fetch gematik-idp authorization resource"
    }
  }
}

# Import Token-Exchange Scope
import {
  for_each = local.import_policy ? toset(["run"]) : toset([])

  to = module.realms["INSTITUTIONS-TI"].keycloak_openid_client_authorization_scope.token_exchange_scope[0]
  id = join("/", [
    "INSTITUTIONS-TI",
    data.keycloak_openid_client.institutions_ti_realm_management[0].resource_server_id,
    data.keycloak_openid_client_authorization_scope.token_exchange_scope[0].id
  ])
}

# Import Gematik IDP Authorization Resource
import {
  for_each = local.import_policy ? toset(["run"]) : toset([])

  to = module.realms["INSTITUTIONS-TI"].keycloak_openid_client_authorization_resource.gematik_idp[0]
  id = join("/", [
    "INSTITUTIONS-TI",
    data.keycloak_openid_client.institutions_ti_realm_management[0].resource_server_id,
    local.gematik_idp_resource_id
  ])
}

# Import Token-Exchange Client Policy
import {
  for_each = local.import_policy ? toset(["run"]) : toset([])

  to = module.realms["INSTITUTIONS-TI"].keycloak_openid_client_client_policy.token_exchange[0]
  id = join("/", [
    "INSTITUTIONS-TI",
    data.keycloak_openid_client.institutions_ti_realm_management[0].resource_server_id,
    data.keycloak_openid_client_authorization_policy.token_exchange_policy[0].id
  ])
}

# Import Gematik IDP Token-Exchange Permission
import {
  for_each = local.import_policy ? toset(["run"]) : toset([])
  to       = module.realms["INSTITUTIONS-TI"].keycloak_openid_client_authorization_permission.gematik_idp_token_exchange[0]
  id = join("/", [
    "INSTITUTIONS-TI",
    data.keycloak_openid_client.institutions_ti_realm_management[0].resource_server_id,
    local.permission_id
  ])
}
