locals {
  idp_mapper = {
    for item in flatten([
      for idp_map in var.idps : [
        for idp, mapper_list in idp_map : [
          for mapper in mapper_list : {
            key = "${idp}-${mapper}"
            value = {
              idp_name      = idp
              mapper_name   = mapper
              mapper        = try(var.idp_mapper_configs[mapper][idp].mapper, var.idp_mapper_configs[mapper].mapper)
              should_create = try(var.idp_mapper_configs[mapper][idp].should_create, var.idp_mapper_configs[mapper].should_create, true)
              extra_config = merge(
                var.idp_mapper_configs[mapper].extra_config,
                try(var.idp_mapper_configs[mapper][idp].extra_config, {})
              )
            }
          }
        ]
      ]
    ]) : item.key => item.value if item.value.should_create
  }
}

resource "keycloak_custom_identity_provider_mapper" "idp_mappers" {
  for_each = local.idp_mapper

  realm                    = keycloak_realm.realm.id
  name                     = each.value.mapper_name
  identity_provider_alias  = each.value.idp_name
  identity_provider_mapper = each.value.mapper

  extra_config = each.value.extra_config

  depends_on = [
    keycloak_oidc_identity_provider.oidc_idps,
    keycloak_saml_identity_provider.saml_idps,
  ]
}
