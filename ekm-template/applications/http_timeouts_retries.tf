module "http_timeouts_retries" {
  source                  = "../../modules/http_timeouts_retries"
  timeout_retry_overrides = var.timeout_retry_overrides
  timeout_retry_defaults  = [{ service = local.service_name, retries = { attempts = 0 } }]
}
