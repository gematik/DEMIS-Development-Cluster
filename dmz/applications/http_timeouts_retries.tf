module "http_timeouts_retries" {
  source                  = "../../modules/http_timeouts_retries"
  timeout_retry_overrides = var.timeout_retry_overrides

  # All deployed services; those without an explicit configuration below receive the
  # built-in common default (timeout 5s, 1 attempt, perTryTimeout 5s).
  service_names = local.service_names

  # Services using the built-in no-retries default (0 attempts)
  no_retries_services = [local.bulk_inbound_name]
}
