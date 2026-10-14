locals {
  all_group_ids = merge(
    { for k, v in keycloak_group.root : k => v.id },
    { for k, v in keycloak_group.level1 : k => v.id },
    { for k, v in keycloak_group.level2 : k => v.id }
  )

  users_surveillance_programs = var.realm_name == "SURVEILLANCE-PROGRAMS" ? {
    for user in var.users : user.username => user
  } : {}

  users = var.realm_name == "SURVEILLANCE-PROGRAMS" ? {} : {
    for user in var.users : user.username => user
  }

  all_users = merge(local.users, local.users_surveillance_programs)
  user_ids = merge(
    { for k, v in keycloak_user.user : k => v.id },
    { for k, v in keycloak_user.users_surveillance_programs : k => v.id }
  )

  user_client_roles = {
    for item in flatten([
      for username, user in local.all_users : [
        for client_name, role_names in try(user.clientRoles, {}) : [
          for role_name in role_names : {
            key = "${username}-${client_name}-${role_name}"
            value = {
              client_name = client_name
              role_name   = role_name
            }
          }
        ]
      ]
    ]) : item.key => item.value
  }
}

resource "keycloak_user" "user" {
  for_each = local.users
  realm_id = keycloak_realm.realm.id
  username = each.value.username

  email          = each.value.email
  email_verified = each.value.emailVerified
  first_name     = each.value.firstName
  last_name      = each.value.lastName
  enabled        = each.value.enabled

  attributes = each.value.attributes

  dynamic "federated_identity" {
    for_each = each.value.federatedIdentities
    content {
      identity_provider = federated_identity.value.identityProvider
      user_id           = federated_identity.value.userId
      user_name         = federated_identity.value.userName
    }
  }

  dynamic "initial_password" {
    for_each = each.value.password ? [1] : []
    content {
      value     = try(var.password_users[each.value.username], "${var.keycloak_default_user_pwd}${each.value.username}")
      temporary = false
    }
  }

  lifecycle {
    ignore_changes = [attributes["lastLoginDate"]]
  }

  depends_on = [keycloak_realm_user_profile.userprofile, keycloak_realm_user_profile.userprofile_surveillance_programs]
}

resource "keycloak_user" "users_surveillance_programs" {
  for_each = local.users_surveillance_programs
  realm_id = keycloak_realm.realm.id
  username = each.value.username

  email          = each.value.email
  email_verified = each.value.emailVerified
  first_name     = each.value.firstName
  last_name      = each.value.lastName
  enabled        = each.value.enabled

  attributes = each.value.attributes

  dynamic "initial_password" {
    for_each = each.value.password ? [1] : []
    content {
      value     = try(var.password_users[each.value.username], "${var.keycloak_default_user_pwd}${each.value.username}")
      temporary = false
    }
  }

  lifecycle {
    ignore_changes = [
      attributes["SP-User-ID"],
      attributes["lastLonginDate"],
    ]
  }

  depends_on = [keycloak_realm_user_profile.userprofile, keycloak_realm_user_profile.userprofile_surveillance_programs]
}

data "keycloak_role" "realm_defaul_role" {
  realm_id = keycloak_realm.realm.id
  name     = "default-roles-${lower(keycloak_realm.realm.id)}"
}

resource "keycloak_user_groups" "user_groups" {
  for_each = { for user in local.all_users : user.username => user if length(user.groups) > 0 }

  realm_id = keycloak_realm.realm.id
  user_id  = local.user_ids[each.key]

  group_ids = [
    for group_name in each.value.groups : local.all_group_ids[group_name]
    if contains(keys(local.all_group_ids), group_name)
  ]
}

data "keycloak_role" "client_roles" {
  for_each = {
    for key, value in local.user_client_roles : key => value
    if contains(keys(keycloak_openid_client.clients), value.client_name)
  }

  realm_id   = keycloak_realm.realm.id
  client_id  = keycloak_openid_client.clients[each.value.client_name].id
  name       = each.value.role_name
  depends_on = [keycloak_openid_client.clients, keycloak_role.client_roles]
}


resource "keycloak_user_roles" "roles" {
  for_each = local.all_users

  realm_id = keycloak_realm.realm.id
  user_id  = local.user_ids[each.key]

  role_ids = distinct(concat(
    [
      for role_name in each.value.realmRoles :
      role_name == data.keycloak_role.realm_defaul_role.name
      ? data.keycloak_role.realm_defaul_role.id
      : keycloak_role.roles[role_name].id
      if role_name == data.keycloak_role.realm_defaul_role.name || contains(keys(keycloak_role.roles), role_name)
    ],
    flatten([
      for client_name, role_names in try(each.value.clientRoles, {}) : [
        for role_name in role_names : coalesce(
          try(keycloak_role.client_roles["${client_name}-${role_name}"].id, null),
          try(data.keycloak_role.client_roles["${each.key}-${client_name}-${role_name}"].id, null)
        )
        if try(keycloak_role.client_roles["${client_name}-${role_name}"].id, null) != null ||
        try(data.keycloak_role.client_roles["${each.key}-${client_name}-${role_name}"].id, null) != null
      ]
    ])
  ))

  depends_on = [
    keycloak_role.roles,
    keycloak_role.client_roles,
    data.keycloak_role.client_roles,
    keycloak_user.user,
    keycloak_user.users_surveillance_programs,
  ]
}