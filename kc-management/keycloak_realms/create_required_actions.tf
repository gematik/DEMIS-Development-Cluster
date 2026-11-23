resource "keycloak_required_action" "required_action" {
  for_each = var.required_action_config
  realm_id = keycloak_realm.realm.realm
  alias    = each.key
  enabled  = each.value.enabled
  name     = each.value.name
  config   = try(each.value.config, null)
}
