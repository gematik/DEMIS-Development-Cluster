locals {
  realm_management_authorization_enabled = var.realm_name == "INSTITUTIONS-TI"
  gematik_idp_enabled                    = contains([for idp in var.idps : keys(idp)[0]], "gematik-idp")
  token_exchange_enabled                 = local.realm_management_authorization_enabled && local.gematik_idp_enabled
}

resource "keycloak_openid_client_authorization_scope" "token_exchange_scope" {
  count = local.realm_management_authorization_enabled ? 1 : 0

  realm_id           = keycloak_realm.realm.id
  resource_server_id = coalesce(lookup(var.client_uuids, "realm-management", null), keycloak_openid_client.clients["realm-management"].id)
  name               = "token-exchange"
  display_name       = "Token Exchange"

  depends_on = [
    keycloak_openid_client.clients["realm-management"]
  ]
}

resource "keycloak_openid_client_authorization_resource" "gematik_idp" {
  count = local.token_exchange_enabled ? 1 : 0

  realm_id           = keycloak_realm.realm.id
  resource_server_id = coalesce(lookup(var.client_uuids, "realm-management", null), keycloak_openid_client.clients["realm-management"].id)
  name               = "idp.resource.${keycloak_oidc_identity_provider.oidc_idps["gematik-idp"].internal_id}"
  type               = "IdentityProvider"

  scopes = [
    keycloak_openid_client_authorization_scope.token_exchange_scope[0].name
  ]

  depends_on = [
    keycloak_oidc_identity_provider.oidc_idps
  ]
}

resource "keycloak_openid_client_client_policy" "token_exchange" {
  count = local.token_exchange_enabled ? 1 : 0

  realm_id           = keycloak_realm.realm.id
  resource_server_id = coalesce(lookup(var.client_uuids, "realm-management", null), keycloak_openid_client.clients["realm-management"].id)
  name               = "token-exchange-client-policy"
  logic              = "NEGATIVE"
  decision_strategy  = "UNANIMOUS"
  clients = [
    keycloak_openid_client.clients["account"].id,
    keycloak_openid_client.clients["account-console"].id,
    keycloak_openid_client.clients["broker"].id,
    keycloak_openid_client.clients["admin-cli"].id,
  ]
}

resource "keycloak_openid_client_authorization_permission" "gematik_idp_token_exchange" {
  count = local.token_exchange_enabled ? 1 : 0

  realm_id           = keycloak_realm.realm.id
  resource_server_id = coalesce(lookup(var.client_uuids, "realm-management", null), keycloak_openid_client.clients["realm-management"].id)
  name               = "token-exchange.permission.idp.${keycloak_oidc_identity_provider.oidc_idps["gematik-idp"].internal_id}"
  type               = "scope"
  decision_strategy  = "UNANIMOUS"

  resources = [keycloak_openid_client_authorization_resource.gematik_idp[0].id]
  scopes    = [keycloak_openid_client_authorization_scope.token_exchange_scope[0].id]
  policies  = [keycloak_openid_client_client_policy.token_exchange[0].id]
}
