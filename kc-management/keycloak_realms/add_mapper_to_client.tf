locals {
  default_mapper = "oidc-usermodel-attribute-mapper"

  client_mapper = {
    for item in flatten([
      for clients_map in var.clients : [
        for client_name, client_cfg in clients_map : [
          for mapper in try(client_cfg.mappers, []) : {
            key = "${client_name}-${mapper}"
            value = {
              client_name     = client_name
              mapper_name     = mapper
              config          = var.client_mapper_configs[mapper].config
              protocol_mapper = try(var.client_mapper_configs[mapper].protocol_mapper, local.default_mapper)
            }
          }
        ]
      ]
    ]) : item.key => item.value
  }
}

resource "keycloak_generic_protocol_mapper" "protocol_mappers" {
  for_each = local.client_mapper

  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.clients[each.value.client_name].id
  name            = each.value.mapper_name
  protocol        = "openid-connect"
  protocol_mapper = each.value.protocol_mapper
  config          = each.value.config
}

# ============================================================================
# === Pruning: mapper created outside of Terraform ===========================
# ============================================================================
locals {
  mapper_owned_clients = {
    for client_name, client_cfg in merge(var.clients...) :
    client_name => toset(client_cfg.mappers)
    if !try(var.openid_clients[client_name][var.realm_name].defaultClient, var.openid_clients[client_name].defaultClient, false)
    # Clients are not part of the state yet, e.g. on an initial setup or in a refresh-only plan.
    && contains(keys(keycloak_openid_client.clients), client_name)
  }

  # A 404 (e.g. client not present yet on an initial setup) means there is nothing to prune.
  actual_client_mappers = {
    for client_name, response in data.http.actual_client_mappers :
    client_name => [for mapper in try(jsondecode(response.response_body), []) : mapper if response.status_code == 200]
  }

  undeclared_client_mappers = {
    for item in flatten([
      for client_name, declared_mappers in local.mapper_owned_clients : [
        for mapper in local.actual_client_mappers[client_name] : {
          key     = "${client_name}/${mapper.name}"
          request = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/clients/${keycloak_openid_client.clients[client_name].id}/protocol-mappers/models/${mapper.id}"
        } if !contains(declared_mappers, mapper.name)
      ]
    ]) : item.key => item.request
  }
}

data "http" "actual_client_mappers" {
  for_each = local.mapper_owned_clients

  url      = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/clients/${keycloak_openid_client.clients[each.key].id}/protocol-mappers/models"
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
      error_message = "(Realm: ${var.realm_name}) Failed to fetch protocol mappers for client: '${each.key}'"
    }
  }
}

resource "terraform_data" "prune_undeclared_client_mappers" {
  triggers_replace = sort(keys(local.undeclared_client_mappers))

  provisioner "local-exec" {
    environment = {
      KEYCLOAK_TOKEN  = var.keycloak_admin_token
      INSECURE        = tostring(var.insecure_connection)
      DELETE_REQUESTS = join("\n", values(local.undeclared_client_mappers))
    }
    command = "bash ${path.module}/.scripts/delete-keycloak-resources.sh"
  }

  depends_on = [keycloak_generic_protocol_mapper.protocol_mappers]
}