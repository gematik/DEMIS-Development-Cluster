locals {
  insecure_connection = startswith(var.stage_specific_keycloak_config.provider_connection_url, "https") ? var.insecure_connection : true
  user_files = {
    master                = "${local.environment_data_path}/keycloak-users/gematik-master.users.json",
    LAB                   = "${local.environment_data_path}/keycloak-users/gematik-LAB.users.json",
    HOSPITAL              = "${local.environment_data_path}/keycloak-users/gematik-HOSPITAL.users.json",
    PORTAL                = "${local.environment_data_path}/keycloak-users/gematik-PORTAL.users.json",
    OEGD                  = "${local.environment_data_path}/keycloak-users/gematik-OEGD.users.json",
    INSTITUTIONS-TI       = "${local.environment_data_path}/keycloak-users/gematik-INSTITUTIONS-TI.users.json",
    SURVEILLANCE-PROGRAMS = "${local.environment_data_path}/keycloak-users/gematik-SURVEILLANCE-PROGRAMS.users.json"
  }

  keycloak_realms_structure = yamldecode(templatefile("${path.module}/realm_structures/master.tftpl.yaml", {
    feature_flags = var.project_feature_flags
    config = {
      with_testsuite_client = nonsensitive(var.keycloak_testsuite_client_secret != null)
    }
  }))

  keycloak_realms = {
    for realm, config in local.keycloak_realms_structure : realm => config
    if contains(var.managed_realms, realm)
  }

  users = {
    for key, file in local.user_files : key => (
      fileexists("${path.module}/${file}") ? [
        for user in jsondecode(file("${path.module}/${file}")) : {
          id            = try(user.id, null)
          username      = user.username
          firstName     = try(user.firstName, "")
          lastName      = try(user.lastName, "")
          email         = try(user.email, "")
          emailVerified = try(user.emailVerified, true)
          enabled       = try(user.enabled, true)
          groups = distinct(concat(
            [for group in try(user.groups, []) : element(split("/", group), length(split("/", group)) - 1) if group != "default_groups"],
            contains(try(user.groups, []), "default_groups") ? try(local.keycloak_realms[key].default_groups, []) : []
          ))
          realmRoles  = try(user.realmRoles, [])
          clientRoles = try(user.clientRoles, {})
          password    = length([for credential in try(user.credentials, []) : credential if try(credential.type, "") == "password"]) > 0
          attributes = {
            for key, value in try(user.attributes, {}) : key => try(join("##", value), tostring(value))
          }
          federatedIdentities = try(user.federatedIdentities, [])
        }
      ] : []
    )
  }


  # Ancestor lookup (same logic as create_groups.tf)
  import_level1_ancestors = { for k, v in local.level1_groups : k => [v.parent] }
  import_level2_ancestors = {
    for k, v in local.level2_groups : k => [
      v.parent,
      local.level1_groups[v.parent].parent
    ]
  }

  # Expand groups to include all ancestors per realm
  expanded_groups_per_realm = {
    for realm in keys(local.keycloak_realms) : realm => toset(flatten([
      for g in try(local.keycloak_realms[realm].groups, []) : concat(
        [g],
        try(local.import_level2_ancestors[g], []),
        try(local.import_level1_ancestors[g], [])
      )
    ]))
  }
}

module "realms" {
  for_each = local.keycloak_realms
  source   = "./keycloak_realms"

  realm_name                = each.key
  managed_realms            = var.managed_realms
  clients                   = try(each.value.clients, [])
  users                     = try(local.users[each.key], [])
  roles                     = try(each.value.roles, [])
  disabled_clients          = try(each.value.disabled_clients, [])
  event_listener            = try(each.value.event_listener, ["jboss-logging"])
  keycloak_root_groups      = local.root_groups
  keycloak_level1_groups    = local.level1_groups
  keycloak_level2_groups    = local.level2_groups
  expanded_groups_per_realm = local.expanded_groups_per_realm
  idps                      = try(each.value.idps, [])
  auth_flows                = try(each.value.auth_flows, [])
  keycloak_default_user_pwd = var.keycloak_default_user_pwd
  openid_clients            = local.openid_clients[each.key]
  default_groups            = try(each.value.default_groups, [])
  roles_config              = local.roles_config
  idp_configs               = local.idp_configs
  auth_flow_configs         = local.auth_flow_configs[each.key]
  idp_mapper_configs        = local.idp_mapper_configs
  client_mapper_configs     = local.client_mapper_configs
  is_production             = var.is_production
  realm_config              = try(var.realm_config[each.key], {})
  certs                     = lookup(var.keycloak_certs, each.key, [])
  password_users            = var.password_users

  client_uuids = { for k, v in data.keycloak_openid_client.clients : split("/", k)[1] => v.id if split("/", k)[0] == each.key }
}
