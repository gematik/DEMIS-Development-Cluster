locals {
  selected_auth_flows = {
    for flow in var.auth_flows : flow => var.auth_flow_configs[flow]
    if contains(keys(var.auth_flow_configs), flow)
  }

  auth_flow_executions = {
    for item in flatten([
      for flow_key, flow in local.selected_auth_flows : [
        for idx, execution in flow.execution : {
          key           = "${flow_key}-${execution.authenticator}"
          flow_key      = flow_key
          priority      = execution.priority
          requirement   = execution.requirement
          authenticator = execution.authenticator
          config        = try(execution.config, null)
          alias         = try(execution.alias, null)
        }
      ]
    ]) : item.key => item
  }
}

resource "keycloak_authentication_flow" "flows" {
  for_each    = local.selected_auth_flows
  realm_id    = keycloak_realm.realm.id
  alias       = each.key
  provider_id = try(each.value.provider_id, "basic-flow")
}

resource "keycloak_authentication_execution" "executions" {
  for_each          = local.auth_flow_executions
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.flows[each.value.flow_key].alias
  authenticator     = each.value.authenticator
  priority          = each.value.priority
  requirement       = each.value.requirement
}

resource "keycloak_authentication_execution_config" "execution_configs" {
  for_each     = { for k, v in local.auth_flow_executions : k => v if v.config != null }
  realm_id     = keycloak_realm.realm.id
  execution_id = keycloak_authentication_execution.executions[each.key].id
  alias        = each.value.alias
  config       = each.value.config
}

resource "keycloak_authentication_bindings" "bind_direct_grant_to_demis_test_password_grant" {
  count             = contains(keys(local.selected_auth_flows), "Direct Grant Mutual TLS") && contains(flatten([for client_map in var.clients : keys(client_map)]), "demis-test-password-grant") ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  direct_grant_flow = keycloak_authentication_flow.flows["Direct Grant Mutual TLS"].alias
}
