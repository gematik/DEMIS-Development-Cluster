locals {

  # Service account role assignments in the form "source_client/role", e.g. "realm-management/view-users"
  client_service_account_roles = merge([
    for client_name, client_cfg in merge(var.clients...) : {
      for sa_role in try(client_cfg.service_account_roles, []) :
      "${client_name}-${replace(sa_role, "/", "-")}" => merge(
        { client_name = client_name },
        regex("^(?P<source_client_name>[^/]+)/(?P<role_name>.+)$", sa_role)
      )
    }
  ]...)
}

resource "keycloak_openid_client_service_account_role" "service_account_roles" {
  for_each = local.client_service_account_roles

  realm_id                = keycloak_realm.realm.id
  service_account_user_id = keycloak_openid_client.clients[each.value.client_name].service_account_user_id
  client_id               = coalesce(lookup(var.client_uuids, each.value.source_client_name, null), keycloak_openid_client.clients[each.value.source_client_name].id)
  role                    = each.value.role_name

  depends_on = [keycloak_openid_client.clients]
}