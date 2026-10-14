locals {
  # Flattened map of all client_roles referenced by any root/level1/level2 group, keyed by "client_id-name"
  group_client_roles = {
    for item in flatten([
      for g in [var.keycloak_root_groups, var.keycloak_level1_groups, var.keycloak_level2_groups] : [
        for k, v in g : [
          for cr in try(v.client_roles, []) : {
            client = cr.client
            name   = cr.name
          }
          # Only clients that are actually managed in this realm (may be empty on the
          # first plan, the roles are then assigned on a subsequent run)
          if contains(keys(keycloak_openid_client.clients), cr.client)
        ]
        if contains(var.expanded_groups_per_realm[var.realm_name], k)
      ]
    ]) : "${item.client}-${item.name}" => item
  }
}

data "keycloak_role" "roles" {
  for_each = {
    for key, value in local.group_client_roles : key => value
  }

  realm_id   = keycloak_realm.realm.id
  client_id  = keycloak_openid_client.clients[each.value.client].id
  name       = each.value.name
  depends_on = [keycloak_openid_client.clients]
}

# #############################################################################
# # Level 0: Root Groups Roles
# #############################################################################
resource "keycloak_group_roles" "root_group_roles" {
  for_each = { for k, v in var.keycloak_root_groups : k => v if contains(var.expanded_groups_per_realm[var.realm_name], k) }
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.root[each.key].id

  role_ids = concat(
    [
      for r in try(each.value.roles, []) : keycloak_role.roles[r].id
      if contains(var.roles, r)
    ],
    [
      for cr in try(each.value.client_roles, []) : data.keycloak_role.roles["${cr.client}-${cr.name}"].id
      if contains(keys(data.keycloak_role.roles), "${cr.client}-${cr.name}")
    ]
  )
}

# #############################################################################
# # Level 1: Level 1 Groups Roles
# #############################################################################
resource "keycloak_group_roles" "level1_group_roles" {
  for_each = { for k, v in var.keycloak_level1_groups : k => v if contains(var.expanded_groups_per_realm[var.realm_name], k) }
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.level1[each.key].id

  role_ids = concat(
    [
      for r in try(each.value.roles, []) : keycloak_role.roles[r].id
      if contains(var.roles, r)
    ],
    [
      for cr in try(each.value.client_roles, []) : data.keycloak_role.roles["${cr.client}-${cr.name}"].id
      if contains(keys(data.keycloak_role.roles), "${cr.client}-${cr.name}")
    ]
  )
}

# #############################################################################
# # Level 2: Level 2 Groups Roles
# #############################################################################
resource "keycloak_group_roles" "level2_group_roles" {
  for_each = { for k, v in var.keycloak_level2_groups : k => v if contains(var.expanded_groups_per_realm[var.realm_name], k) }
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.level2[each.key].id

  role_ids = concat(
    [
      for r in try(each.value.roles, []) : keycloak_role.roles[r].id
      if contains(var.roles, r)
    ],
    [
      for cr in try(each.value.client_roles, []) : data.keycloak_role.roles["${cr.client}-${cr.name}"].id
      if contains(keys(data.keycloak_role.roles), "${cr.client}-${cr.name}")
    ]
  )
}
