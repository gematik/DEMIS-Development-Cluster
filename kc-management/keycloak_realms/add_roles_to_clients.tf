locals {

  client_roles = {
    for item in flatten([
      for clients_map in var.clients : [
        for client_name, client_cfg in clients_map : [
          for role in try(client_cfg.roles, []) : {
            key = "${client_name}-${role}"
            value = {
              client_name = client_name
              role_name   = role
            }
          }
        ]
      ]
    ]) : item.key => item.value
  }
}

resource "keycloak_role" "client_roles" {
  for_each  = local.client_roles
  realm_id  = keycloak_realm.realm.id
  name      = each.value.role_name
  client_id = keycloak_openid_client.clients[each.value.client_name].id
  description = try(
    var.roles_config[each.value.role_name][var.realm_name].desc,
    var.roles_config[each.value.role_name].desc
  )
}
