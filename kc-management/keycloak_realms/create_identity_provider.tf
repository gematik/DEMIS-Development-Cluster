resource "keycloak_saml_identity_provider" "saml_idps" {
  for_each = { for idp in var.idps : keys(idp)[0] => idp if try(var.idp_configs[var.realm_name][keys(idp)[0]].type, "") == "saml" }

  realm        = keycloak_realm.realm.id
  alias        = each.key
  display_name = try(var.idp_configs[var.realm_name][each.key].display_name, "")
  gui_order    = try(var.idp_configs[var.realm_name][each.key].gui_order, null)
  sync_mode    = try(var.idp_configs[var.realm_name][each.key].sync_mode, "IMPORT")

  entity_id = var.idp_configs[var.realm_name][each.key].entity_id

  backchannel_supported                  = try(var.idp_configs[var.realm_name][each.key].backchannel_supported, false)
  post_binding_response                  = try(var.idp_configs[var.realm_name][each.key].post_binding_response, false)
  post_binding_logout                    = try(var.idp_configs[var.realm_name][each.key].post_binding_logout, false)
  post_binding_authn_request             = try(var.idp_configs[var.realm_name][each.key].post_binding_authn_request, false)
  store_token                            = try(var.idp_configs[var.realm_name][each.key].store_token, false)
  trust_email                            = try(var.idp_configs[var.realm_name][each.key].trust_email, false)
  force_authn                            = try(var.idp_configs[var.realm_name][each.key].force_authn, false)
  want_assertions_signed                 = try(var.idp_configs[var.realm_name][each.key].want_assertions_signed, false)
  want_assertions_encrypted              = try(var.idp_configs[var.realm_name][each.key].want_assertions_encrypted, false)
  signature_algorithm                    = try(var.idp_configs[var.realm_name][each.key].signature_algorithm, "RSA_SHA256_MGF1")
  name_id_policy_format                  = try(var.idp_configs[var.realm_name][each.key].name_id_policy_format, "Persistent")
  signing_certificate                    = try(var.idp_configs[var.realm_name][each.key].signing_certificate, "")
  hide_on_login_page                     = try(var.idp_configs[var.realm_name][each.key].hide_on_login_page, false)
  validate_signature                     = try(var.idp_configs[var.realm_name][each.key].validate_signature, false)
  login_hint                             = try(var.idp_configs[var.realm_name][each.key].login_hint, "")
  xml_sign_key_info_key_name_transformer = try(var.idp_configs[var.realm_name][each.key].xml_sign_key_info_key_name_transformer, "KEY_ID")
  single_sign_on_service_url             = try(var.idp_configs[var.realm_name][each.key].single_sign_on_service_url, "")
  single_logout_service_url              = try(var.idp_configs[var.realm_name][each.key].single_logout_service_url, "")
  principal_type                         = try(var.idp_configs[var.realm_name][each.key].principal_type, null)
  principal_attribute                    = try(var.idp_configs[var.realm_name][each.key].principal_attribute, null)
  authn_context_class_refs               = try(var.idp_configs[var.realm_name][each.key].authn_context_class_refs, [])
  authn_context_comparison_type          = try(var.idp_configs[var.realm_name][each.key].authn_context_comparison_type, null)
  extra_config                           = try(var.idp_configs[var.realm_name][each.key].extra_config, {})

}

resource "keycloak_oidc_identity_provider" "oidc_idps" {
  for_each = { for idp in var.idps : keys(idp)[0] => idp if(try(var.idp_configs[var.realm_name][keys(idp)[0]].type, "") == "oidc" && try(var.idp_configs[var.realm_name][keys(idp)[0]].enabled, true)) }

  realm                         = keycloak_realm.realm.id
  provider_id                   = try(var.idp_configs[var.realm_name][each.key].provider_id, "oidc")
  alias                         = each.key
  authorization_url             = try(var.idp_configs[var.realm_name][each.key].authorization_url, "")
  client_id                     = try(var.idp_configs[var.realm_name][each.key].client_id, "")
  token_url                     = try(var.idp_configs[var.realm_name][each.key].token_url, "")
  issuer                        = try(var.idp_configs[var.realm_name][each.key].issuer, "")
  display_name                  = try(var.idp_configs[var.realm_name][each.key].display_name, "")
  client_secret                 = try(var.idp_configs[var.realm_name][each.key].client_secret, "")
  sync_mode                     = try(var.idp_configs[var.realm_name][each.key].sync_mode, "LEGACY")
  default_scopes                = try(var.idp_configs[var.realm_name][each.key].default_scopes, "")
  backchannel_supported         = try(var.idp_configs[var.realm_name][each.key].backchannel_supported, false)
  store_token                   = try(var.idp_configs[var.realm_name][each.key].store_token, false)
  first_broker_login_flow_alias = try(var.idp_configs[var.realm_name][each.key].first_broker_login_flow_alias, "")
  logout_url                    = try(var.idp_configs[var.realm_name][each.key].logout_url, null)
  user_info_url                 = try(var.idp_configs[var.realm_name][each.key].user_info_url, null)
  validate_signature            = try(var.idp_configs[var.realm_name][each.key].validate_signature, false)
  jwks_url                      = try(var.idp_configs[var.realm_name][each.key].jwks_url, "")
  gui_order                     = try(var.idp_configs[var.realm_name][each.key].gui_order, null)
  trust_email                   = try(var.idp_configs[var.realm_name][each.key].trust_email, false)

  extra_config = try(var.idp_configs[var.realm_name][each.key].extra_config, {
    "clientAuthMethod" = "client_secret_post"
  })
}
