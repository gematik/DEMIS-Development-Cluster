locals {
  no_retries                 = { retries = { attempts = 0 } }
  common_timeout_retry_value = { timeout : "5s", retries = { attempts = 1, perTryTimeout = "5s" } }
}


module "http_timeouts_retries" {
  source                  = "../../modules/http_timeouts_retries"
  timeout_retry_overrides = var.timeout_retry_overrides
  timeout_retry_defaults = [
    merge({ service = local.ars_name }, local.no_retries),
    merge({ service = local.ces_name }, local.common_timeout_retry_value),
    merge({ service = local.dls_reader_name }, local.no_retries),
    merge({ service = local.dls_writer_name }, local.no_retries),
    merge({ service = local.fssr_name }, local.no_retries),
    merge({ service = local.fssw_name }, local.no_retries),
    merge({ service = local.futs_core_name }, local.common_timeout_retry_value),
    merge({ service = local.futs_igs_name }, local.common_timeout_retry_value),
    merge({ service = local.gateway_igs_name }, local.no_retries),
    merge({ service = local.hls_name }, local.common_timeout_retry_value),
    merge({ service = local.igs_name }, local.no_retries),
    merge({ service = local.lcvs_name }, local.common_timeout_retry_value),
    merge({ service = local.minio_name }, { retries = { attempts = 3, perTryTimeout = "300s" } }),
    merge({ service = local.gateway_name }, local.no_retries),
    merge({ service = local.nps_name }, local.no_retries),
    merge({ service = local.nrs_name }, local.common_timeout_retry_value),
    merge({ service = local.fpr_name }, local.no_retries),
    merge({ service = local.pdfgen_name }, local.common_timeout_retry_value),
    merge({ service = local.portal_bedoccupancy_name }, local.no_retries),
    merge({ service = local.portal_disease_name }, local.no_retries),
    merge({ service = local.portal_igs_name }, local.no_retries),
    merge({ service = local.portal_pathogen_name }, local.no_retries),
    merge({ service = local.portal_shell_name }, local.no_retries),
    merge({ service = local.pseudo_name }, local.common_timeout_retry_value),
    merge({ service = local.rps_name }, local.no_retries),
    merge({ service = local.sps_ars_name }, local.no_retries),
    merge({ service = local.fts_name }, local.no_retries),
    merge({ service = local.vs_core_name }, local.common_timeout_retry_value),
    merge({ service = local.vs_igs_name }, local.common_timeout_retry_value),
    merge({ service = local.vs_ars_name }, local.common_timeout_retry_value),
  ]
}
