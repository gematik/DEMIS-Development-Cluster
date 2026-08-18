module "http_timeouts_retries" {
  source                  = "../../modules/http_timeouts_retries"
  timeout_retry_overrides = var.timeout_retry_overrides

  # All deployed services; those without an explicit configuration below receive the
  # built-in common default (timeout 5s, 1 attempt, perTryTimeout 5s).
  service_names = local.service_names

  # Services using the built-in no-retries default (0 attempts)
  no_retries_services = [
    local.ars_name,
    local.dls_reader_name,
    local.dls_writer_name,
    local.fssr_name,
    local.fssw_name,
    local.gateway_igs_name,
    local.igs_name,
    local.gateway_name,
    local.nps_name,
    local.fpr_name,
    local.portal_bedoccupancy_name,
    local.portal_disease_name,
    local.portal_igs_name,
    local.portal_pathogen_name,
    local.portal_shell_name,
    local.rps_name,
    local.sps_ars_name,
    local.fts_name,
  ]

  # Services with non-standard configurations
  custom_timeout_retry = [
    merge({ service = local.object_storage_service_name }, { retries = { attempts = 3, perTryTimeout = "300s" } }),
  ]
}
