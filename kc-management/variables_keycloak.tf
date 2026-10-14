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
  description = "A map of realm specific configurations (can be overritten for each realm 'realm={...}')"
  type = map(object({
    // Login parameter
    edit_username_allowed          = optional(bool, false)
    login_with_email_allowed       = optional(bool, false)
    duplicate_emails_allowed       = optional(bool, false)
    registration_email_as_username = optional(bool, false)
    registration_allowed           = optional(bool, false)
    reset_password_allowed         = optional(bool, false)
    remember_me                    = optional(bool, false)
    verify_email                   = optional(bool, false)

    // Session parameter
    sso_session_idle_timeout             = optional(string, "30m")
    sso_session_max_lifespan             = optional(string, "10h")
    access_code_lifespan_login           = optional(string, "30m")
    access_code_lifespan_user_action     = optional(string, "5m")
    client_session_idle_timeout          = optional(string, "0s")
    client_session_max_lifespan          = optional(string, "0s")
    offline_session_idle_timeout         = optional(string, "720h")
    offline_session_max_lifespan_enabled = optional(bool, false)

    // Token parameter
    oauth2_device_code_lifespan              = optional(string, "10m")
    polling_interval                         = optional(string, 5)
    access_token_lifespan                    = optional(string, "5m")
    access_code_lifespan                     = optional(string, "1m")
    access_token_lifespan_for_implicit_flow  = optional(string, "15m")
    action_token_generated_by_user_lifespan  = optional(string, "5m")
    action_token_generated_by_admin_lifespan = optional(string, "12h")
    default_signature_algorithm              = optional(string, "RS256")
    revoke_refresh_token                     = optional(bool, false)
  }))
}

variable "stage_specific_keycloak_config" {
  type = object({
    # Base URL of the Keycloak instance used for admin API calls. Should be normaly localhost
    demis_keycloak_url      = string
    provider_connection_url = optional(string, "http://127.0.0.1:43434")
    oidc_idp_configs = map(object({
      tokenUrl         = string
      clientId         = string
      authorizationUrl = string
      issuer           = string
    }))
    # The configuration for the Keycloak certificate flow, which is used for certificate based authentication
    realm_specifics = map(object({
      x509_cert_auth_regular_expression      = string
      x509_ocsp_checking_enabled             = bool
      x509_cert_timestamp_validation_enabled = bool
    }))
    saml_idp_configs = map(object({
      service_url            = string
      entity_id              = string
      name_id_policy_format  = string
      principal_type         = string
      want_assertions_signed = bool
      is_enabled             = bool
    }))
    authenticator_configs = object({
      client_id         = string
      user_agent        = string
      openid_config_url = string
      default_scope     = string
    })
    portal_specifics = object({
      demis_home_url                    = string
      meldeportal_redirect_url          = list(string)
      meldeportal_web_origin            = list(string)
      meldeportal_internet_redirect_url = list(string)
      meldeportal_internet_web_origin   = list(string)
    })
  })
  description = "Stage specific Keycloak configuration for the Keycloak Terraform Provider integration"
}
