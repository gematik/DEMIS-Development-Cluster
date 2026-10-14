locals {
  flows_to_get = ["direct grant"]

  realm_clients = {
    for realm in var.managed_realms : "${realm}-realm" => {
      id                 = "${realm}-realm"
      name               = "${realm} Realm"
      defaultClient      = true
      access_type        = "BEARER-ONLY"
      full_scope_allowed = false
    } if(var.realm_name == "master")
  }

  filtered_clients = merge({
    for key, client in var.openid_clients :
    key => client
    if try(client[var.realm_name].defaultClient, client.defaultClient, false) || anytrue([
      for c in var.clients : contains(keys(c), key)
    ])
  }, local.realm_clients)

  clients_with_default_scopes = {
    for key, client in local.filtered_clients :
    key => client
    if try(client.default_scopes, null) != null
  }

  clients_with_optional_scopes = {
    for key, client in local.filtered_clients :
    key => client
    if try(client.optional_scopes, null) != null
  }
}

data "keycloak_authentication_flow" "flows" {
  for_each = toset(local.flows_to_get)
  realm_id = keycloak_realm.realm.id
  alias    = each.key
}


resource "keycloak_openid_client" "clients" {
  for_each = local.filtered_clients

  realm_id  = keycloak_realm.realm.id
  client_id = each.key

  name    = try(each.value[var.realm_name].name, each.value.name, "")
  enabled = contains(var.disabled_clients, each.key) ? false : true

  access_type                         = try(each.value[var.realm_name].access_type, each.value.access_type)
  client_secret_wo                    = try(each.value[var.realm_name].client_secret, each.value.client_secret, null)
  client_secret_wo_version            = try(sha256(try(each.value[var.realm_name].client_secret, each.value.client_secret, null)), null)
  standard_flow_enabled               = try(each.value[var.realm_name].standard_flow_enabled, each.value.standard_flow_enabled, false)
  implicit_flow_enabled               = try(each.value[var.realm_name].implicit_flow_enabled, each.value.implicit_flow_enabled, false)
  direct_access_grants_enabled        = try(each.value[var.realm_name].direct_access_grants_enabled, each.value.direct_access_grants_enabled, false)
  service_accounts_enabled            = try(each.value[var.realm_name].service_accounts_enabled, each.value.service_accounts_enabled, false)
  backchannel_logout_session_required = try(each.value[var.realm_name].backchannel_logout_session_required, each.value.backchannel_logout_session_required, false)
  frontchannel_logout_enabled         = try(each.value[var.realm_name].frontchannel_logout_enabled, each.value.frontchannel_logout_enabled, false)
  pkce_code_challenge_method          = try(each.value[var.realm_name].pkce_code_challenge_method, each.value.pkce_code_challenge_method, null)
  valid_redirect_uris                 = try(each.value[var.realm_name].valid_redirect_uris, each.value.valid_redirect_uris, [])
  valid_post_logout_redirect_uris     = try(each.value[var.realm_name].valid_post_logout_redirect_uris, each.value.valid_post_logout_redirect_uris, null)
  web_origins                         = try(each.value[var.realm_name].web_origins, each.value.web_origins, [])
  full_scope_allowed                  = try(each.value[var.realm_name].full_scope_allowed, each.value.full_scope_allowed, null)
  access_token_lifespan               = try(each.value[var.realm_name].access_token_lifespan, each.value.access_token_lifespan, null)
  base_url                            = try(each.value[var.realm_name].base_url, each.value.base_url, null)
  admin_url                           = try(each.value[var.realm_name].admin_url, each.value.admin_url, null)

  dynamic "authentication_flow_binding_overrides" {
    for_each = try(each.value[var.realm_name].authentication_flow_binding_overrides, each.value.authentication_flow_binding_overrides, null) != null ? [try(each.value[var.realm_name].authentication_flow_binding_overrides, each.value.authentication_flow_binding_overrides)] : []
    iterator = auth
    content {
      direct_grant_id = data.keycloak_authentication_flow.flows[auth.value.direct_grant].id
      browser_id      = try(auth.value.browser, null)
    }
  }

  dynamic "authorization" {
    for_each = try(each.value[var.realm_name].authorization, each.value.authorization, null) != null ? [try(each.value[var.realm_name].authorization, each.value.authorization)] : []
    iterator = auth

    content {
      policy_enforcement_mode          = try(auth.value.policy_enforcement_mode, "ENFORCING")
      decision_strategy                = try(auth.value.decision_strategy, "UNANIMOUS")
      allow_remote_resource_management = try(auth.value.allow_remote_resource_management, false)
      keep_defaults                    = try(auth.value.keep_defaults, false)
    }
  }

  import = try(each.value.defaultClient, false)
}

resource "keycloak_openid_client_default_scopes" "default_scopes" {
  for_each       = local.clients_with_default_scopes
  realm_id       = keycloak_realm.realm.id
  client_id      = keycloak_openid_client.clients[each.key].id
  default_scopes = try(each.value[var.realm_name].default_scopes, try(each.value.default_scopes, []))
  depends_on     = [keycloak_openid_client.clients, keycloak_role.roles]
}

resource "keycloak_openid_client_optional_scopes" "optional_scopes" {
  for_each        = local.clients_with_optional_scopes
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.clients[each.key].id
  optional_scopes = try(each.value[var.realm_name].optional_scopes, try(each.value.optional_scopes, []))
  depends_on      = [keycloak_openid_client.clients, keycloak_role.roles]
}
