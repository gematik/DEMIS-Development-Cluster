locals {

  client_roles = merge([
    for clients_map in var.clients : merge([
      for client_name, client_cfg in clients_map : {
        for role in try(client_cfg.roles, []) : "${client_name}-${role}" => {
          client_name = client_name
          role_name   = role
        }
      }
    ]...)
  ]...)
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

# ============================================================================
# === Pruning: roles created outside of Terraform ============================
# ============================================================================
locals {
  # Keycloak creates this role itself as soon as authorization services are enabled.
  keycloak_generated_client_roles = ["uma_protection"]

  # Default clients ship built-in roles, so only self-defined clients can be owned completely.
  role_owned_clients = {
    for client_name, client_cfg in merge(var.clients...) :
    client_name => toset(concat(client_cfg.roles, local.keycloak_generated_client_roles))
    if !try(var.openid_clients[client_name][var.realm_name].defaultClient, var.openid_clients[client_name].defaultClient, false)
    # Clients are not part of the state yet, e.g. on an initial setup or in a refresh-only plan.
    && contains(keys(keycloak_openid_client.clients), client_name)
  }

  # A 404 (e.g. client not present yet on an initial setup) means there is nothing to prune.
  actual_client_roles = {
    for client_name, response in data.http.actual_client_roles :
    client_name => [for role in try(jsondecode(response.response_body), []) : role if response.status_code == 200]
  }

  # The role id is part of the trigger, so a manually re-created role is pruned again.
  undeclared_client_roles = {
    for item in flatten([
      for client_name, declared_roles in local.role_owned_clients : [
        for role in local.actual_client_roles[client_name] : {
          key     = "${client_name}/${role.name}"
          id      = role.id
          request = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/clients/${keycloak_openid_client.clients[client_name].id}/roles/${replace(urlencode(role.name), "+", "%20")}"
        } if !contains(declared_roles, role.name)
      ]
    ]) : item.key => item
  }
}

data "http" "actual_client_roles" {
  for_each = local.role_owned_clients

  url      = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/clients/${keycloak_openid_client.clients[each.key].id}/roles"
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
      error_message = "(Realm: ${var.realm_name}) Failed to fetch client roles for client: '${each.key}'"
    }
  }
}

resource "terraform_data" "prune_undeclared_client_roles" {
  triggers_replace = sort([for key, item in local.undeclared_client_roles : "${key}#${item.id}"])

  provisioner "local-exec" {
    environment = {
      KEYCLOAK_TOKEN  = var.keycloak_admin_token
      INSECURE        = tostring(var.insecure_connection)
      DELETE_REQUESTS = join("\n", [for item in values(local.undeclared_client_roles) : item.request])
    }
    command = "bash ${path.module}/.scripts/delete-keycloak-resources.sh"
  }

  depends_on = [keycloak_role.client_roles]
}
