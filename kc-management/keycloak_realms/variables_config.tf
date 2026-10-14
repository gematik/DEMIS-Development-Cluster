variable "realm_config" {
  description = "A map of realm specific configurations"
  type = object({
    // Login parameter
    edit_username_allowed          = bool
    login_with_email_allowed       = bool
    duplicate_emails_allowed       = bool
    registration_email_as_username = bool
    registration_allowed           = bool
    reset_password_allowed         = bool
    remember_me                    = bool
    verify_email                   = bool

    // Session parameter
    sso_session_idle_timeout             = string
    sso_session_max_lifespan             = string
    access_code_lifespan_login           = string
    access_code_lifespan_user_action     = string
    client_session_idle_timeout          = string
    client_session_max_lifespan          = string
    offline_session_idle_timeout         = string
    offline_session_max_lifespan_enabled = bool

    // Token parameter
    oauth2_device_code_lifespan              = string
    polling_interval                         = string
    access_token_lifespan                    = string
    access_code_lifespan                     = string
    access_token_lifespan_for_implicit_flow  = string
    action_token_generated_by_user_lifespan  = string
    action_token_generated_by_admin_lifespan = string
    default_signature_algorithm              = string
    revoke_refresh_token                     = bool
  })
}
