
variable "keycloak_default_user_pwd" {
  type        = string
  sensitive   = true
  description = "The default password for Keycloak users"
}

variable "certs" {
  type = list(object({
    name        = string
    cert        = string
    private_key = string
    algorithm   = string
    priority    = number
    provider_id = string
  }))
  sensitive   = true
  description = "A list of Keycloak certificates"
  default     = []
}

variable "password_users" {
  type        = map(string)
  sensitive   = true
  description = "A map of users with different passwords than default, where the key is the username and the value is the password"
}