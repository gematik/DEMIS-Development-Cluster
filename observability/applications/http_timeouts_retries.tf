########################
# Timeouts and retries of the HTTP services in the namespace (timeout_retry_overrides.tfvars)
########################

module "http_timeouts_retries" {
  source = "../../modules/http_timeouts_retries"
  # As in the demis namespace: large objects
  custom_timeout_retry = [
    { service = "object-storage-service", retries = { attempts = 3, perTryTimeout = "300s" } },
  ]
  timeout_retry_overrides = var.timeout_retry_overrides
}
