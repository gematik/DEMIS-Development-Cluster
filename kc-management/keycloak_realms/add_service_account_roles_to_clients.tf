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

# ============================================================================
# === Pruning: assignments created outside of Terraform ======================
# ============================================================================
locals {
  # Default clients come with their own service account assignments, so only self-defined clients can be owned completely.
  service_account_owned_clients = {
    for client_name, client_cfg in merge(var.clients...) :
    client_name => toset(concat(
      client_cfg.service_account_roles,
      # Keycloak assigns the client's own generated roles to its service account.
      [for role in local.keycloak_generated_client_roles : "${client_name}/${role}"]
    ))
    if !try(var.openid_clients[client_name][var.realm_name].defaultClient, var.openid_clients[client_name].defaultClient, false)
    && try(var.openid_clients[client_name][var.realm_name].service_accounts_enabled, var.openid_clients[client_name].service_accounts_enabled, false)
    # Clients are not part of the state yet, e.g. on an initial setup or in a refresh-only plan.
    && contains(keys(keycloak_openid_client.clients), client_name)
  }

  # A 404 (e.g. client or service account user not present yet on an initial setup) means there is nothing to prune.
  actual_service_account_role_mappings = {
    for client_name, response in data.http.actual_service_account_roles :
    client_name => response.status_code == 200 ? try(jsondecode(response.response_body).clientMappings, {}) : {}
  }

  undeclared_service_account_roles = {
    for item in flatten([
      for client_name, declared_roles in local.service_account_owned_clients : [
        for source_client_name, mapping in local.actual_service_account_role_mappings[client_name] : [
          for role in mapping.mappings : {
            key = "${client_name} -> ${source_client_name}/${role.name}"
            request = join("\t", [
              "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/users/${keycloak_openid_client.clients[client_name].service_account_user_id}/role-mappings/clients/${mapping.id}",
              jsonencode([{ id = role.id, name = role.name }])
            ])
          } if !contains(declared_roles, "${source_client_name}/${role.name}")
        ]
      ]
    ]) : item.key => item.request
  }
}

data "http" "actual_service_account_roles" {
  for_each = local.service_account_owned_clients

  url      = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/users/${keycloak_openid_client.clients[each.key].service_account_user_id}/role-mappings"
  method   = "GET"
  insecure = var.insecure_connection

  request_headers = {
    Authorization = "Bearer ${var.keycloak_admin_token}"
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
      error_message = "(Realm: ${var.realm_name}) Failed to fetch service account role mappings for client: '${each.key}'"
    }
  }
}

resource "terraform_data" "prune_undeclared_service_account_roles" {
  triggers_replace = sort(keys(local.undeclared_service_account_roles))

  provisioner "local-exec" {
    environment = {
      KEYCLOAK_TOKEN  = var.keycloak_admin_token
      INSECURE        = tostring(var.insecure_connection)
      DELETE_REQUESTS = join("\n", values(local.undeclared_service_account_roles))
    }
    command = "bash ${path.module}/.scripts/delete-keycloak-resources.sh"
  }

  depends_on = [keycloak_openid_client_service_account_role.service_account_roles]
}