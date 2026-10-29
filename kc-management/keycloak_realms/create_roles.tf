
resource "keycloak_role" "roles" {
  for_each    = toset(var.roles)
  realm_id    = keycloak_realm.realm.id
  name        = each.key
  description = try(var.roles_config[each.key][var.realm_name].desc, var.roles_config[each.key].desc)
}

# ============================================================================
# === Pruning: roles created outside of Terraform ============================
# ============================================================================
locals {
  # Keycloak creates these realm roles itself, the master realm additionally ships its admin roles.
  keycloak_generated_realm_roles = concat(
    local.default_roles,
    var.realm_name == "master" ? ["admin", "create-realm"] : []
  )

  declared_realm_roles = toset(concat(var.roles, local.keycloak_generated_realm_roles))

  # A 404 (e.g. realm not present yet on an initial setup) means there is nothing to prune.
  actual_realm_roles = [for role in try(jsondecode(data.http.actual_realm_roles.response_body), []) : role if data.http.actual_realm_roles.status_code == 200]

  # The role id is part of the trigger, so a manually re-created role is pruned again.
  undeclared_realm_roles = {
    for role in local.actual_realm_roles : role.name => {
      id      = role.id
      request = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/roles/${replace(urlencode(role.name), "+", "%20")}"
    } if !contains(local.declared_realm_roles, role.name)
  }
}

data "http" "actual_realm_roles" {
  url      = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/roles"
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
      error_message = "(Realm: ${var.realm_name}) Failed to fetch realm roles"
    }
  }
}

resource "terraform_data" "prune_undeclared_realm_roles" {
  triggers_replace = sort([for name, item in local.undeclared_realm_roles : "${name}#${item.id}"])

  provisioner "local-exec" {
    environment = {
      KEYCLOAK_TOKEN  = var.keycloak_admin_token
      INSECURE        = tostring(var.insecure_connection)
      DELETE_REQUESTS = join("\n", [for item in values(local.undeclared_realm_roles) : item.request])
    }
    command = "bash ${path.module}/.scripts/delete-keycloak-resources.sh"
  }

  depends_on = [keycloak_role.roles]
}
