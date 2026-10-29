locals {
  client_mapper_configs = yamldecode(templatefile("${path.module}/catalogue_structures/client_mapper_configs.tftpl.yaml", {}))
  idp_mapper_configs    = yamldecode(templatefile("${path.module}/catalogue_structures/idp_mapper_configs.tftpl.yaml", { local_cluster = var.local_cluster }))
  roles_config          = yamldecode(templatefile("${path.module}/catalogue_structures/roles_config.tftpl.yaml", {}))

  group_catalogues = {
    root   = yamldecode(templatefile("${path.module}/catalogue_structures/root_groups.tftpl.yaml", {}))
    level1 = yamldecode(templatefile("${path.module}/catalogue_structures/level1_groups.tftpl.yaml", {}))
    level2 = yamldecode(templatefile("${path.module}/catalogue_structures/level2_groups.tftpl.yaml", {}))
  }

  group_catalogues_per_realm = {
    for realm in keys(local.keycloak_realms) : realm => {
      for level, groups in local.group_catalogues : level => {
        for key, group in groups : key => merge(group, {
          client_roles = concat(
            try(group.client_roles, []),
            lookup(var.kc_options.additional_client_roles_to_groups, key, [])
          )
          attributes = lookup(lookup(var.kc_options.replace_group_attributes, realm, {}), key, try(group.attributes, {}))
        })
      }
    }
  }

  auth_flow_configs = {
    for realm in keys(local.keycloak_realms) : realm => yamldecode(templatefile(
      "${path.module}/catalogue_structures/auth_flow_configs.tftpl.yaml", {
        realm                          = realm
        stage_specific_keycloak_config = var.stage_specific_keycloak_config
      }
    ))
  }

  # Secrets/certs are injected after yamldecode so only the leaf attributes stay
  # sensitive; routing them through templatefile would taint the whole map and
  # break for_each (which relies on non-sensitive keys).
  idp_configs_base = {
    for realm in keys(local.keycloak_realms) : realm => yamldecode(templatefile(
      "${path.module}/catalogue_structures/idp_configs.tftpl.yaml", {
        realm                          = realm
        local_cluster                  = var.local_cluster
        stage_specific_keycloak_config = var.stage_specific_keycloak_config
      }
    ))
  }

  idp_configs = {
    for realm, idps in local.idp_configs_base : realm => merge(idps, {
      "gematik-idp" = merge(idps["gematik-idp"], { client_secret = var.keycloak_gematik_idp_client_secret })
      "entra-id"    = merge(idps["entra-id"], { client_secret = var.keycloak_entra_id_client_secret })
      "bundid-idp"  = merge(idps["bundid-idp"], { signing_certificate = var.saml_signing_certs["bundid-idp"] })
      "muk"         = merge(idps["muk"], { signing_certificate = var.saml_signing_certs["muk"] })
    })
  }

  openid_default_secret_clients = [
    "token-exchange-client", "demis-adapter", "demis-test-password-grant", "demis-test",
    "demis-analyzer", "demis-importer", "aeskulab21", "devagency", "gumax", "isga",
    "mikropro", "octoware", "profile-loader", "survnet",
  ]

  openid_clients_base = {
    for realm in keys(local.keycloak_realms) : realm => yamldecode(templatefile(
      "${path.module}/catalogue_structures/openid_clients.tftpl.yaml", {
        realm                          = realm
        stage_specific_keycloak_config = var.stage_specific_keycloak_config
        kc_options                     = var.kc_options
      }
    ))
  }

  openid_clients = {
    for realm, clients in local.openid_clients_base : realm => merge(
      clients,
      { for name in local.openid_default_secret_clients : name => merge(clients[name], { client_secret = var.keycloak_default_client_secrets }) },
      {
        "cus-cli"          = merge(clients["cus-cli"], { client_secret = var.keycloak_cus_client_secret })
        "testsuite-client" = merge(clients["testsuite-client"], { client_secret = var.keycloak_testsuite_client_secret })
        "PORTAL"           = merge(clients["admin-cli"]["PORTAL"], { client_secret = var.keycloak_portal_admin_cli_client_secret })
        "realm-management" = merge(clients["realm-management"], {
          "INSTITUTIONS-TI" = merge(clients["realm-management"]["INSTITUTIONS-TI"], { client_secret = var.keycloak_institutions_ti_realm_management_client_secret })
        })
      }
    )
  }
}
