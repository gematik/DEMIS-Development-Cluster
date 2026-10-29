# A 404 means the realm does not exist yet (initial setup). The realm defaults are not available then.
locals {
  realm_scopes_available = alltrue([
    for response in [
      data.http.realm_client_scopes,
      data.http.realm_default_client_scopes,
      data.http.realm_optional_client_scopes
    ] : response.status_code == 200
  ])

  # The realm defaults also contain SAML scopes, which the OIDC scope resources reject.
  openid_client_scope_names = toset(local.realm_scopes_available ? [
    for scope in jsondecode(data.http.realm_client_scopes.response_body) :
    scope.name if scope.protocol == "openid-connect"
  ] : [])

  # Scopes Keycloak itself attaches to a newly created client in this realm, used when a client declares none.
  realm_baseline_default_scopes = local.realm_scopes_available ? [
    for scope in jsondecode(data.http.realm_default_client_scopes.response_body) :
    scope.name if contains(local.openid_client_scope_names, scope.name)
  ] : []
  realm_baseline_optional_scopes = local.realm_scopes_available ? [
    for scope in jsondecode(data.http.realm_optional_client_scopes.response_body) :
    scope.name if contains(local.openid_client_scope_names, scope.name)
  ] : []

  # Default clients ship their own scope set, so they are only managed once they declare one explicitly.
  scope_owned_clients = {
    for client_name, client in local.filtered_clients :
    client_name => {
      default_scopes  = try(client[var.realm_name].default_scopes, client.default_scopes, local.realm_baseline_default_scopes)
      optional_scopes = try(client[var.realm_name].optional_scopes, client.optional_scopes, local.realm_baseline_optional_scopes)
    }
    # BEARER-ONLY clients reject any scope assignment
    if try(client[var.realm_name].access_type, client.access_type, "") != "BEARER-ONLY" && (
      !try(client[var.realm_name].defaultClient, client.defaultClient, false) ||
      try(client[var.realm_name].default_scopes, client.default_scopes, null) != null
      ) && (
      # Without the realm defaults, clients relying on them are skipped until the realm exists.
      local.realm_scopes_available || (
        try(client[var.realm_name].default_scopes, client.default_scopes, null) != null &&
        try(client[var.realm_name].optional_scopes, client.optional_scopes, null) != null
      )
    )
  }
}

data "http" "realm_client_scopes" {
  url      = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/client-scopes"
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
      error_message = "(Realm: ${var.realm_name}) Failed to fetch the realm client scopes"
    }
  }
}

data "http" "realm_default_client_scopes" {
  url      = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/default-default-client-scopes"
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
      error_message = "(Realm: ${var.realm_name}) Failed to fetch the realm default client scopes"
    }
  }
}

data "http" "realm_optional_client_scopes" {
  url      = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/default-optional-client-scopes"
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
      error_message = "(Realm: ${var.realm_name}) Failed to fetch the realm optional client scopes"
    }
  }
}

# Both resources are exclusive: scopes attached outside of Terraform are removed on apply.
resource "keycloak_openid_client_default_scopes" "default_scopes" {
  for_each       = local.scope_owned_clients
  realm_id       = keycloak_realm.realm.id
  client_id      = keycloak_openid_client.clients[each.key].id
  default_scopes = each.value.default_scopes
  depends_on     = [keycloak_openid_client.clients, keycloak_role.roles]
}

resource "keycloak_openid_client_optional_scopes" "optional_scopes" {
  for_each        = local.scope_owned_clients
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.clients[each.key].id
  optional_scopes = each.value.optional_scopes
  depends_on      = [keycloak_openid_client.clients, keycloak_role.roles]
}
