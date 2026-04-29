module "dmz_services" {
  source                          = "./applications"
  external_chart_path             = local.chart_source_path
  docker_registry                 = var.docker_registry
  helm_repository                 = var.helm_repository
  helm_repository_username        = var.helm_repository_username
  helm_repository_password        = var.helm_repository_password
  target_namespace                = module.dmz_namespace.name
  pull_secrets                    = local.pull_secrets_credentials
  deployment_information          = local.deployment_information
  core_hostname                   = module.endpoints.core_hostname
  portal_hostname                 = module.endpoints.portal_hostname
  meldung_hostname                = module.endpoints.meldung_hostname
  cluster_gateway                 = module.endpoints.istio_gateway_fullname
  debug_enabled                   = var.debug_enabled
  istio_enabled                   = var.istio_enabled
  context_path                    = var.context_path
  feature_flags                   = module.application_flags.service_feature_flags
  config_options                  = module.application_flags.service_config_options
  resource_definitions            = module.application_resources.service_resource_definitions
  timeout_retry_overrides         = var.timeout_retry_overrides
  reset_values                    = var.reset_values
  rabbitmq_pvc_config             = var.rabbitmq_pvc_config
  allow_even_rabbitmq_replicas    = var.allow_even_rabbitmq_replicas
  database_target_host            = var.database_target_host
  deployment_timeout              = var.deployment_timeout
  external_routing_configurations = try(module.external_routing_configurations[0], { rules = {} })
  project_feature_flags           = var.project_feature_flags
  # Thread the maintenance-mode status and PVC names as explicit inputs instead of using depends_on.
  # This establishes the apply-time ordering (activate → deploy) through data-flow,
  # which avoids the "known after apply" propagation that module-level depends_on causes.
  maintenance_mode_trigger = module.activate_maintenance_mode.maintenance_mode_status
  pvc_trigger              = [for pvc in module.persistent_volume_claims : pvc.metadata.name]

  # Secrets and Credentials needed for the applications
  postgres_server_certificate                 = var.postgres_server_certificate
  postgres_root_ca_certificate                = var.postgres_root_ca_certificate
  postgres_server_key                         = var.postgres_server_key
  database_credentials                        = var.database_credentials
  ars_bulk_upload_hmac_secret                 = var.ars_bulk_upload_hmac_secret
  ars_bis_in_queue_encryption_current_secret  = var.ars_bis_in_queue_encryption_current_secret
  ars_bis_in_queue_encryption_previous_secret = var.ars_bis_in_queue_encryption_previous_secret
  ars_secure_queue_encryption_current_secret  = var.ars_secure_queue_encryption_current_secret
  rabbitmq_username                           = var.rabbitmq_username
  rabbitmq_password                           = var.rabbitmq_password
  rabbitmq_password_hash                      = var.rabbitmq_password_hash
  rabbitmq_erlang_cookie                      = var.rabbitmq_erlang_cookie
}
