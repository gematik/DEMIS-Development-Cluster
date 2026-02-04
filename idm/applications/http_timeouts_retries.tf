locals {
  common_timeout_retry_value = { timeout : "5s", retries = { attempts = 1, perTryTimeout = "5s" } }
}

module "http_timeouts_retries" {
  source                  = "../../modules/http_timeouts_retries"
  timeout_retry_overrides = var.timeout_retry_overrides
  timeout_retry_defaults = [
    merge({ service = local.bundid_name }, local.common_timeout_retry_value),
    merge({ service = local.gemidp_name }, local.common_timeout_retry_value),
    merge({ service = local.keycloak_name }, local.common_timeout_retry_value),
  ]
}
