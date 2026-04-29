locals {
  no_retries                 = { retries = { attempts = 0 } }
  common_timeout_retry_value = { timeout : "5s", retries = { attempts = 1, perTryTimeout = "5s" } }
}

module "http_timeouts_retries" {
  source                  = "../../modules/http_timeouts_retries"
  timeout_retry_overrides = var.timeout_retry_overrides
  timeout_retry_defaults = [
    merge({ service = local.are_gateway_name }, local.no_retries),
    merge({ service = local.are_nps_name }, local.no_retries),
    merge({ service = local.portal_are_name }, local.no_retries),
    merge({ service = local.vs_are_name }, local.common_timeout_retry_value)
  ]
}
