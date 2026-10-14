
resource "keycloak_role" "roles" {
  for_each    = toset(var.roles)
  realm_id    = keycloak_realm.realm.id
  name        = each.key
  description = try(var.roles_config[each.key][var.realm_name].desc, var.roles_config[each.key].desc)
}
