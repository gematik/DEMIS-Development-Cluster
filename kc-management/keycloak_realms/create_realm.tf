locals {
  surveillance_programs = ["ARE", "IGS"]
  realm_default_roles = {
    master                = ["offline_access", "uma_authorization", "account/manage-account", "account/view-profile"],
    LAB                   = ["account/view-profile", "notification-api/lab-notification-sender"]
    PORTAL                = ["offline_access", "uma_authorization", "account/view-profile"],
    HOSPITAL              = ["account/view-profile", "notification-entry-service/lab-notification-sender", "notification-entry-service/disease-notification-sender"],
    OEGD                  = ["account/view-profile", "notification-clearing-api/lab-notification-receiver"],
    SURVEILLANCE-PROGRAMS = ["account/view-profile", "account/manage-account", "offline_access", "uma_authorization"],
    INSTITUTIONS-TI       = ["account/view-profile", "account/manage-account", "offline_access", "uma_authorization"],
  }
}

resource "keycloak_realm" "realm" {
  # General settings
  realm             = var.realm_name
  enabled           = true
  display_name      = var.realm_name == "master" ? "Keycloak" : var.realm_name
  display_name_html = "<b>The realm for ${var.realm_name}</b>"

  # Realm attributes that could not be set directly in the resource block
  attributes = {
    # Events settings
    adminEventsExpiration = 2592000
    # Token settings
    shortVerificationUri                                              = ""
    parRequestUriLifespan                                             = 60
    "actionTokenGeneratedByUserLifespan.execute-actions"              = ""
    "actionTokenGeneratedByUserLifespan.idp-verify-account-via-email" = ""
    "actionTokenGeneratedByUserLifespan.reset-credentials"            = ""
    "actionTokenGeneratedByUserLifespan.verify-email"                 = ""
  }

  # Login settings
  edit_username_allowed          = var.realm_config.edit_username_allowed
  login_with_email_allowed       = var.realm_config.login_with_email_allowed
  duplicate_emails_allowed       = var.realm_config.duplicate_emails_allowed
  registration_email_as_username = var.realm_config.registration_email_as_username
  registration_allowed           = var.realm_config.registration_allowed
  reset_password_allowed         = var.realm_config.reset_password_allowed
  remember_me                    = var.realm_config.remember_me
  verify_email                   = var.realm_config.verify_email

  # Theme settings
  login_theme   = "demis-login-theme"
  account_theme = "demis-login-theme"
  admin_theme   = "keycloak.v2"
  email_theme   = "demis-login-theme"

  # Localization settings
  dynamic "internationalization" {
    for_each = var.realm_name == "PORTAL" ? { enabled = true } : {}
    content {
      supported_locales = [
        "de"
      ]
      default_locale = "de"
    }
  }

  # Security defenses settings
  security_defenses {
    headers {
      x_frame_options                     = "SAMEORIGIN"
      content_security_policy             = "frame-src 'self'; frame-ancestors 'self'; object-src 'none';"
      content_security_policy_report_only = ""
      x_content_type_options              = "nosniff"
      x_xss_protection                    = "none"
      strict_transport_security           = "max-age=31536000; includeSubDomains"
      referrer_policy                     = "no-referrer"
    }
  }

  # Session settings
  sso_session_idle_timeout             = try(var.realm_config[var.realm_name].sso_session_idle_timeout, var.realm_config.sso_session_idle_timeout)
  sso_session_max_lifespan             = try(var.realm_config[var.realm_name].sso_session_max_lifespan, var.realm_config.sso_session_max_lifespan)
  client_session_idle_timeout          = try(var.realm_config[var.realm_name].client_session_idle_timeout, var.realm_config.client_session_idle_timeout)
  client_session_max_lifespan          = try(var.realm_config[var.realm_name].client_session_max_lifespan, var.realm_config.client_session_max_lifespan)
  offline_session_idle_timeout         = try(var.realm_config[var.realm_name].offline_session_idle_timeout, var.realm_config.offline_session_idle_timeout)
  offline_session_max_lifespan_enabled = try(var.realm_config[var.realm_name].offline_session_max_lifespan_enabled, var.realm_config.offline_session_max_lifespan_enabled, false)
  access_code_lifespan_login           = try(var.realm_config[var.realm_name].access_code_lifespan_login, var.realm_config.access_code_lifespan_login)
  access_code_lifespan_user_action     = try(var.realm_config[var.realm_name].access_code_lifespan_user_action, var.realm_config.access_code_lifespan_user_action)

  # Token settings
  default_signature_algorithm              = try(var.realm_config[var.realm_name].default_signature_algorithm, var.realm_config.default_signature_algorithm, "RS256")
  oauth2_device_code_lifespan              = try(var.realm_config[var.realm_name].oauth2_device_code_lifespan, var.realm_config.oauth2_device_code_lifespan)
  oauth2_device_polling_interval           = try(var.realm_config[var.realm_name].polling_interval, var.realm_config.polling_interval)
  revoke_refresh_token                     = try(var.realm_config[var.realm_name].revoke_refresh_token, var.realm_config.revoke_refresh_token, false)
  access_token_lifespan                    = try(var.realm_config[var.realm_name].access_token_lifespan, var.realm_config.access_token_lifespan)
  access_token_lifespan_for_implicit_flow  = try(var.realm_config[var.realm_name].access_token_lifespan_for_implicit_flow, var.realm_config.access_token_lifespan_for_implicit_flow)
  access_code_lifespan                     = try(var.realm_config[var.realm_name].access_code_lifespan, var.realm_config.access_code_lifespan)
  action_token_generated_by_user_lifespan  = try(var.realm_config[var.realm_name].action_token_generated_by_user_lifespan, var.realm_config.action_token_generated_by_user_lifespan)
  action_token_generated_by_admin_lifespan = try(var.realm_config[var.realm_name].action_token_generated_by_admin_lifespan, var.realm_config.action_token_generated_by_admin_lifespan)


  web_authn_passwordless_policy {
    discoverable_credential       = "not specified"
    user_verification_requirement = "not specified"
  }

  lifecycle {
    prevent_destroy = (var.realm_name == "master" || var.is_production)
  }

}

resource "keycloak_realm_events" "realm_events" {
  realm_id = keycloak_realm.realm.id

  events_enabled               = false
  admin_events_enabled         = true
  admin_events_details_enabled = true

  events_listeners = var.event_listener
}

resource "keycloak_realm_user_profile" "userprofile" {
  count                      = var.realm_name != "SURVEILLANCE-PROGRAMS" ? 1 : 0
  realm_id                   = keycloak_realm.realm.id
  unmanaged_attribute_policy = "ENABLED"
  attribute {
    name         = "username"
    display_name = "$${username}"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    validator {
      name = "length"
      config = {
        min = "1"
        max = "255"
      }
    }
  }
  attribute {
    name         = "email"
    display_name = "$${email}"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    validator {
      name = "length"
      config = {
        min = "3"
        max = "255"
      }
    }
  }
  attribute {
    name         = "firstName"
    display_name = "$${firstName}"
    validator {
      name = "length"
      config = {
        max = "255"
      }
    }
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
  }
  attribute {
    name         = "lastName"
    display_name = "$${lastName}"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    validator {
      name = "length"
      config = {
        max = "255"
      }
    }
  }

  group {
    name                = "user-metadata"
    display_header      = "User metadata"
    display_description = "Attributes, which refer to user metadata"
  }
}

resource "keycloak_realm_user_profile" "userprofile_surveillance_programs" {
  count                      = var.realm_name == "SURVEILLANCE-PROGRAMS" ? 1 : 0
  realm_id                   = keycloak_realm.realm.id
  unmanaged_attribute_policy = "DISABLED"
  attribute {
    name         = "username"
    display_name = "$${username}"
    permissions {
      view = ["admin"]
      edit = ["admin"]
    }
  }
  attribute {
    name         = "SP-User-ID"
    display_name = "SP-User-ID"
    annotations = {
      inputHelperTextBefore = "Surveillance-Programm Institutions-ID"
    }
    permissions {
      view = ["admin"]
      edit = []
    }
  }
  attribute {
    name         = "email"
    display_name = "$${email}"
    validator {
      name = "length"
      config = {
        max = "255"
      }
    }
    permissions {
      view = ["admin"]
      edit = ["admin"]
    }
  }
  attribute {
    name               = "PLZ"
    required_for_roles = ["admin", "user"]
    annotations = {
      inputHelperTextBefore = "Postleitzahl der Institution"
    }
    validator {
      name = "pattern"
      config = {
        pattern       = "^[0-9]{5}$"
        error-message = "Ungültige PLZ"
      }
    }

    permissions {
      view = ["admin"]
      edit = ["admin"]
    }
  }
  attribute {
    name         = "Surveillance-Programm"
    display_name = "Surveillance-Programm"

    annotations = {
      inputHelperTextBefore = "Teilnahme am Surveillance-Programm"
      inputType             = "multiselect-checkboxes"
      inputOptionsFromValidation = jsonencode({
        "options" : local.surveillance_programs
      })

    }

    validator {
      name = "options"
      config = {
        options = jsonencode(local.surveillance_programs)
      }
    }

    validator {
      name = "multivalued"
      config = {
        min = "1",
        max = local.surveillance_programs != null ? tostring(length(local.surveillance_programs)) : "1"
      }
    }

    permissions {
      view = ["admin"]
      edit = ["admin"]
    }
  }
  attribute {
    name         = "Einrichtungsname"
    display_name = "Einrichtungsname"
    permissions {
      view = ["admin"]
      edit = ["admin"]
    }
  }
  attribute {
    name         = "Ansprechperson"
    display_name = "Ansprechperson"
    permissions {
      view = ["admin"]
      edit = ["admin"]
    }
  }

  group {
    name                = "user-metadata"
    display_header      = "User metadata"
    display_description = "Attributes, which refer to user metadata"
  }
}

# User registration configuration (Default roles)
resource "keycloak_default_roles" "default_roles" {
  realm_id      = keycloak_realm.realm.id
  default_roles = try(local.realm_default_roles[var.realm_name], [])
  depends_on    = [keycloak_openid_client.clients, keycloak_role.roles, keycloak_role.client_roles]
}

# User registration configuration (Default groups)
resource "keycloak_default_groups" "default_groups" {
  realm_id = keycloak_realm.realm.id
  group_ids = [
    for group_name in var.default_groups : local.all_group_ids[group_name]
    if contains(keys(local.all_group_ids), group_name)
  ]
  depends_on = [keycloak_openid_client.clients, keycloak_group.root, keycloak_group.level1, keycloak_group.level2]
}
