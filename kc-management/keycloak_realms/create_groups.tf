#############################################################################
# Level 0: Root Groups (no parent)
#############################################################################
resource "keycloak_group" "root" {
  for_each = { for k, v in var.keycloak_root_groups : k => v if contains(var.expanded_groups_per_realm[var.realm_name], k) }

  realm_id   = keycloak_realm.realm.id
  name       = each.value.name
  attributes = try(each.value.attributes, {})
}

#############################################################################
# Level 1: Groups with root parent
#############################################################################
resource "keycloak_group" "level1" {
  for_each = { for k, v in var.keycloak_level1_groups : k => v if contains(var.expanded_groups_per_realm[var.realm_name], k) }

  realm_id   = keycloak_realm.realm.id
  name       = each.value.name
  parent_id  = keycloak_group.root[each.value.parent].id
  attributes = try(each.value.attributes, {})
}

#############################################################################
# Level 2: Groups with level 1 parent
#############################################################################
resource "keycloak_group" "level2" {
  for_each = { for k, v in var.keycloak_level2_groups : k => v if contains(var.expanded_groups_per_realm[var.realm_name], k) }

  realm_id   = keycloak_realm.realm.id
  name       = each.value.name
  parent_id  = keycloak_group.level1[each.value.parent].id
  attributes = try(each.value.attributes, {})
}
