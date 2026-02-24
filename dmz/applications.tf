module "dmz_services" {
  source                        = "./applications"
  external_chart_path           = local.chart_source_path
  docker_registry               = var.docker_registry
  helm_repository               = var.helm_repository
  helm_repository_username      = var.helm_repository_username
  helm_repository_password      = var.helm_repository_password
  target_namespace              = var.target_namespace
  pull_secrets                  = local.pull_secrets_credentials
  deployment_information        = local.deployment_information
  core_hostname                 = module.endpoints.core_hostname
  portal_hostname               = module.endpoints.portal_hostname
  meldung_hostname              = module.endpoints.meldung_hostname
  cluster_gateway               = module.endpoints.istio_gateway_fullname
  debug_enabled                 = var.debug_enabled
  istio_enabled                 = var.istio_enabled
  context_path                  = var.context_path
  feature_flags                 = module.application_flags.service_feature_flags
  config_options                = module.application_flags.service_config_options
  resource_definitions          = module.application_resources.service_resource_definitions
  istio_proxy_default_resources = module.application_resources.istio_proxy_default_resources
  timeout_retry_overrides       = var.timeout_retry_overrides
  reset_values                  = var.reset_values
  rabbitmq_pvc_config           = var.rabbitmq_pvc_config
  allow_even_rabbitmq_replicas  = var.allow_even_rabbitmq_replicas
  database_target_host          = var.database_target_host

  # Secrets and Credentials needed for the applications
  postgres_server_certificate  = var.postgres_server_certificate
  postgres_root_ca_certificate = var.postgres_root_ca_certificate
  postgres_server_key          = var.postgres_server_key
  database_credentials         = var.database_credentials
  ars_bulk_upload_hmac_secret  = var.ars_bulk_upload_hmac_secret
  rabbitmq_username            = var.rabbitmq_username
  rabbitmq_password            = var.rabbitmq_password
  rabbitmq_password_hash       = var.rabbitmq_password_hash
  rabbitmq_erlang_cookie       = var.rabbitmq_erlang_cookie

  depends_on = [module.persistent_volume_claims, module.pull_secrets, module.activate_maintenance_mode.set_maintenance_mode]
}
