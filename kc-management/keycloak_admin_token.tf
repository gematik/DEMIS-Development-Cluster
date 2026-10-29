locals {
  keycloak_admin_token = try(jsondecode(data.http.keycloak_admin_token.response_body).access_token, "")
}

# Always-available admin token used by the realm module to check client existence at plan time.
data "http" "keycloak_admin_token" {
  url      = "${var.stage_specific_keycloak_config.provider_connection_url}/realms/master/protocol/openid-connect/token"
  method   = "POST"
  insecure = local.insecure_connection

  request_headers = {
    Content-Type = "application/x-www-form-urlencoded"
  }

  request_body = "grant_type=client_credentials&client_id=terraform-client&client_secret=${urlencode(var.keycloak_terraform_client_secret)}"

  retry {
    attempts     = 10
    max_delay_ms = 5000
    min_delay_ms = 1000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200 && try(jsondecode(self.response_body).access_token, "") != ""
      error_message = "Failed to obtain Keycloak admin token. A running and reachable Keycloak instance is required for the import process."
    }
  }

}
