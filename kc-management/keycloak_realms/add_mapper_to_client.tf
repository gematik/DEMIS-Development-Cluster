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
