module "demis_services" {
  source                            = "./applications"
  external_chart_path               = local.chart_source_path
  is_local_mode                     = local.is_local_mode
  production_mode                   = !(strcontains(local.stage_name, "local") || strcontains(local.stage_name, "dev"))
  docker_registry                   = var.docker_registry
  helm_repository                   = var.helm_repository
  helm_repository_username          = var.helm_repository_username
  helm_repository_password          = var.helm_repository_password
  istio_routing_chart_version       = local.istio_routing_chart_version
  target_namespace                  = var.target_namespace
  pull_secrets                      = local.pull_secrets_credentials
  redis_cus_reader_user             = var.redis_cus_reader_user
  deployment_information            = local.deployment_information
  fhir_storage_purger_suspend       = var.fhir_storage_purger_suspend
  fhir_storage_purger_cron_schedule = var.fhir_storage_purger_cron_schedule
  core_hostname                     = module.endpoints.core_hostname
  portal_hostname                   = module.endpoints.portal_hostname
  meldung_hostname                  = module.endpoints.meldung_hostname
  keycloak_internal_hostname        = module.endpoints.keycloak_svc_hostname
  auth_hostname                     = module.endpoints.auth_hostname
  storage_hostname                  = module.endpoints.storage_hostname
  cluster_gateway                   = module.endpoints.istio_gateway_fullname
  fhir_profile_snapshots            = local.fhir_profile_snapshots
  igs_profile_snapshots             = local.igs_profile_snapshots
  ars_profile_snapshots             = local.ars_profile_snapshots
  routing_data_version              = local.routing_data_version
  database_target_host              = var.database_target_host
  s3_hostname                       = var.s3_hostname
  s3_port                           = var.s3_port
  debug_enabled                     = var.debug_enabled
  istio_enabled                     = var.istio_enabled
  context_path                      = var.context_path
  feature_flags                     = module.application_flags.service_feature_flags
  config_options                    = module.application_flags.service_config_options
  resource_definitions              = module.application_resources.service_resource_definitions

  depends_on = [module.persistent_volume_claims, module.pull_secrets, module.activate_maintenance_mode.set_maintenance_mode]
}
