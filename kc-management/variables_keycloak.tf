variable "managed_realms" {
  type        = list(string)
  description = "List of Keycloak realms to be managed by Terraform"
  default     = []
  validation {
    condition     = alltrue([for realm in var.managed_realms : realm != ""])
    error_message = "managed_realms: Realms must not be empty strings."
  }
}

variable "realms_to_import" {
  type        = list(string)
  description = "Comma-separated list of Keycloak realms to be imported into Terraform state"
  default     = []
  validation {
    condition     = alltrue([for realm in var.realms_to_import : realm != ""])
    error_message = "realms_to_import: Realms must not be empty strings."
  }
}

variable "realm_config" {
  description = "A map of realm specific configurations (can be overritten for each realm 'realm={...}', unset attributes fall back to local.realm_config_defaults)"
  type = map(object({
    // Login parameter
    edit_username_allowed          = optional(bool)
    login_with_email_allowed       = optional(bool)
    duplicate_emails_allowed       = optional(bool)
    registration_email_as_username = optional(bool)
    registration_allowed           = optional(bool)
    reset_password_allowed         = optional(bool)
    remember_me                    = optional(bool)
    verify_email                   = optional(bool)

    // Session parameter
    sso_session_idle_timeout             = optional(string)
    sso_session_max_lifespan             = optional(string)
    access_code_lifespan_login           = optional(string)
    access_code_lifespan_user_action     = optional(string)
    client_session_idle_timeout          = optional(string)
    client_session_max_lifespan          = optional(string)
    offline_session_idle_timeout         = optional(string)
    offline_session_max_lifespan_enabled = optional(bool)

    // Token parameter
    oauth2_device_code_lifespan              = optional(string)
    polling_interval                         = optional(string)
    access_token_lifespan                    = optional(string)
    access_code_lifespan                     = optional(string)
    access_token_lifespan_for_implicit_flow  = optional(string)
    action_token_generated_by_user_lifespan  = optional(string)
    action_token_generated_by_admin_lifespan = optional(string)
    default_signature_algorithm              = optional(string)
    revoke_refresh_token                     = optional(bool)
  }))
}

locals {
  realm_config_defaults = {
    // Login parameter
    edit_username_allowed          = false
    login_with_email_allowed       = false
    duplicate_emails_allowed       = false
    registration_email_as_username = false
    registration_allowed           = false
    reset_password_allowed         = false
    remember_me                    = false
    verify_email                   = false

    // Session parameter
    sso_session_idle_timeout             = "30m"
    sso_session_max_lifespan             = "10h"
    access_code_lifespan_login           = "30m"
    access_code_lifespan_user_action     = "5m"
    client_session_idle_timeout          = "0s"
    client_session_max_lifespan          = "0s"
    offline_session_idle_timeout         = "720h"
    offline_session_max_lifespan_enabled = false

    // Token parameter
    oauth2_device_code_lifespan              = "10m"
    polling_interval                         = "5"
    access_token_lifespan                    = "5m"
    access_code_lifespan                     = "1m"
    access_token_lifespan_for_implicit_flow  = "15m"
    action_token_generated_by_user_lifespan  = "5m"
    action_token_generated_by_admin_lifespan = "12h"
    default_signature_algorithm              = "RS256"
    revoke_refresh_token                     = false
  }
}

variable "stage_specific_keycloak_config" {
  type = object({
    # Base URL of the Keycloak instance used for admin API calls. Should be normaly localhost
    demis_keycloak_url      = string
    provider_connection_url = optional(string, "http://127.0.0.1:43434")
    themes = optional(map(string), {
      login_theme   = "demis-login-theme"
      account_theme = "demis-login-theme"
      admin_theme   = "keycloak.v2"
      email_theme   = "demis-login-theme"
    })
    oidc_idp_configs = map(object({
      tokenUrl         = string
      clientId         = string
      authorizationUrl = string
      issuer           = string
      sync_mode        = optional(string, "LEGACY")
    }))
    # The configuration for the Keycloak certificate flow, which is used for certificate based authentication
    realm_specifics = map(object({
      x509_cert_auth_regular_expression      = string
      x509_ocsp_checking_enabled             = bool
      x509_cert_timestamp_validation_enabled = bool
      x509_cert_auth_ocsp_fail_open          = bool
    }))
    saml_idp_configs = map(object({
      service_url                   = string
      entity_id                     = string
      name_id_policy_format         = string
      principal_type                = optional(string, "SUBJECT")
      principal_attribute           = optional(string, null)
      want_assertions_signed        = bool
      is_enabled                    = bool
      sync_mode                     = optional(string, "IMPORT")
      authn_context_class_refs      = optional(list(string), null)
      authn_context_comparison_type = optional(string, null)
    }))
    authenticator_configs = object({
      client_id         = string
      user_agent        = string
      openid_config_url = string
      default_scope     = string
    })
    portal_specifics = object({
      demis_home_url                    = string
      internet_home_url                 = optional(string, null)
      meldeportal_redirect_url          = list(string)
      meldeportal_web_origin            = list(string)
      meldeportal_internet_redirect_url = list(string)
      meldeportal_internet_web_origin   = list(string)
    })
  })
  description = "Stage specific Keycloak configuration for the Keycloak Terraform Provider integration"
}
