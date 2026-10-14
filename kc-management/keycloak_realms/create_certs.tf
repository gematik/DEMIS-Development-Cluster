resource "keycloak_realm_keystore_rsa" "certs" {
  for_each = { for cert in nonsensitive(var.certs) : cert.name => nonsensitive(cert) if contains(["rsa", "rsa-enc"], cert.provider_id) }
  name     = each.value.name
  realm_id = keycloak_realm.realm.id

  enabled = true
  active  = true

  private_key = each.value.private_key
  certificate = each.value.cert

  priority    = each.value.priority
  algorithm   = each.value.algorithm
  provider_id = each.value.provider_id
}

