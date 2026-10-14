variable "keycloak_terraform_client_secret" {
  type        = string
  sensitive   = true
  description = "The Secret for service account terraform_client"
}

variable "keycloak_default_user_pwd" {
  type        = string
  sensitive   = true
  description = "The default password for Keycloak users"
}

variable "keycloak_portal_admin_cli_client_secret" {
  type        = string
  sensitive   = true
  description = "The secret for the Keycloak Portal Admin CLI client"
}

variable "keycloak_institutions_ti_realm_management_client_secret" {
  type        = string
  sensitive   = true
  description = "The secret for the Keycloak Institutions TI Realm Management client"
}

variable "keycloak_default_client_secrets" {
  type        = string
  sensitive   = true
  description = "The default secret for the Keycloak clients"
}

variable "keycloak_cus_client_secret" {
  type        = string
  sensitive   = true
  description = "secret for cus client"
}

variable "keycloak_testsuite_client_secret" {
  type        = string
  sensitive   = true
  description = "secret for testsuite client. Optional. Is not set, testsuite client is not created."
  default     = null
}

variable "keycloak_gematik_idp_client_secret" {
  type        = string
  sensitive   = true
  description = "The secret for the Keycloak Gematik IDP client"
}

variable "keycloak_entra_id_client_secret" {
  type        = string
  sensitive   = true
  description = "The secret for the Keycloak Entra ID client"
  default     = ""
}

variable "keycloak_certs" {
  type = map(list(object({
    name        = string
    cert        = string
    private_key = string
    algorithm   = optional(string, "RS256")
    priority    = optional(number, 101)
    provider_id = optional(string, "rsa")
  })))
  sensitive   = true
  description = "A map of Keycloak certificates, where the key is the certificate name and the value is the certificate content"
  default     = {}
}

variable "saml_signing_certs" {
  type        = map(string)
  sensitive   = true
  description = "A map of SAML signing certificates, where the key is the saml-idp-provider name and the value is the certificate content"
  default     = {}
}

variable "password_users" {
  type        = map(string)
  sensitive   = true
  description = "A map of users with different passwords than default, where the key is the username and the value is the password"
  default     = {}
}