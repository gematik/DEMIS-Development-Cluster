module "demis_services" {
  source                                          = "./applications"
  external_chart_path                             = local.chart_source_path
  is_local_mode                                   = local.is_local_mode
  production_mode                                 = !(strcontains(local.stage_name, "local") || strcontains(local.stage_name, "dev"))
  docker_registry                                 = var.docker_registry
  helm_repository                                 = var.helm_repository
  helm_repository_username                        = var.helm_repository_username
  helm_repository_password                        = var.helm_repository_password
  target_namespace                                = var.target_namespace
  pull_secrets                                    = local.pull_secrets_credentials
  deployment_information                          = local.deployment_information
  fhir_storage_purger_suspend                     = var.fhir_storage_purger_suspend
  fhir_storage_purger_cron_schedule               = var.fhir_storage_purger_cron_schedule
  destination_lookup_purger_suspend               = var.destination_lookup_purger_suspend
  destination_lookup_purger_cron_schedule         = var.destination_lookup_purger_cron_schedule
  surveillance_pseudonym_purger_ars_suspend       = var.surveillance_pseudonym_purger_ars_suspend
  surveillance_pseudonym_purger_ars_cron_schedule = var.surveillance_pseudonym_purger_ars_cron_schedule
  core_hostname                                   = module.endpoints.core_hostname
  portal_hostname                                 = module.endpoints.portal_hostname
  meldung_hostname                                = module.endpoints.meldung_hostname
  keycloak_internal_hostname                      = module.endpoints.keycloak_svc_hostname
  auth_hostname                                   = module.endpoints.auth_hostname
  storage_hostname                                = module.endpoints.storage_hostname
  cluster_gateway                                 = module.endpoints.istio_gateway_fullname
  database_target_host                            = var.database_target_host
  s3_hostname                                     = var.s3_hostname
  s3_port                                         = var.s3_port
  debug_enabled                                   = var.debug_enabled
  istio_enabled                                   = var.istio_enabled
  context_path                                    = var.context_path
  feature_flags                                   = module.application_flags.service_feature_flags
  config_options                                  = module.application_flags.service_config_options
  resource_definitions                            = module.application_resources.service_resource_definitions
  istio_proxy_default_resources                   = module.application_resources.istio_proxy_default_resources
  timeout_retry_overrides                         = var.timeout_retry_overrides
  profile_provisioning_mode_vs_core               = var.profile_provisioning_mode_vs_core
  profile_provisioning_mode_vs_igs                = var.profile_provisioning_mode_vs_igs
  profile_provisioning_mode_vs_ars                = var.profile_provisioning_mode_vs_ars
  reset_values                                    = var.reset_values

  # Secrets and Credentials needed for the applications
  redis_cus_reader_user        = var.redis_cus_reader_user
  redis_cus_reader_password    = var.redis_cus_reader_password
  minio_root_user              = var.minio_root_user
  minio_root_password          = var.minio_root_password
  s3_tls_credential            = var.s3_tls_credential
  postgres_server_certificate  = var.postgres_server_certificate
  postgres_root_ca_certificate = var.postgres_root_ca_certificate
  postgres_server_key          = var.postgres_server_key
  database_credentials         = var.database_credentials
  service_accounts             = var.service_accounts
  ars_pseudo_hash_pepper       = var.ars_pseudo_hash_pepper

  depends_on = [module.persistent_volume_claims, module.pull_secrets, module.activate_maintenance_mode.set_maintenance_mode]
}
