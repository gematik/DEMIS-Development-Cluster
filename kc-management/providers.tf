terraform {
  required_version = ">=1.9.0"
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.6.2"
    }

    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.10.0"
    }
  }
}

provider "keycloak" {
  client_id                = "terraform-client"
  client_secret            = var.keycloak_terraform_client_secret
  url                      = var.stage_specific_keycloak_config.provider_connection_url
  initial_login            = false
  tls_insecure_skip_verify = local.insecure_connection
}
