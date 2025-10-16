module "idm_services" {
  source                             = "./applications"
  external_chart_path                = local.chart_source_path
  is_local_mode                      = local.is_local_mode
  docker_registry                    = var.docker_registry
  helm_repository                    = var.helm_repository
  helm_repository_username           = var.helm_repository_username
  helm_repository_password           = var.helm_repository_password
  target_namespace                   = var.target_namespace
  pull_secrets                       = local.pull_secrets_credentials
  deployment_information             = local.deployment_information
  certificate_update_service_suspend = var.certificate_update_service_suspend
  certificate_update_cron_schedule   = var.certificate_update_cron_schedule
  keycloak_user_purger_suspend       = var.keycloak_user_purger_suspend
  keycloak_user_purger_cron_schedule = var.keycloak_user_purger_cron_schedule
  core_hostname                      = module.endpoints.core_hostname
  auth_hostname                      = module.endpoints.auth_hostname
  bundid_idp_hostname                = module.endpoints.bundid_idp_hostname
  ti_idp_hostname                    = module.endpoints.ti_idp_hostname
  database_target_host               = var.database_target_host
  debug_enabled                      = var.debug_enabled
  istio_enabled                      = var.istio_enabled
  feature_flags                      = module.application_flags.service_feature_flags
  config_options                     = module.application_flags.service_config_options
  resource_definitions               = module.application_resources.service_resource_definitions
  ti_idp_server_url                  = var.ti_idp_server_url
  ti_idp_client_name                 = var.ti_idp_client_name
  ti_idp_redirect_uri                = var.ti_idp_redirect_uri
  ti_idp_return_sso_token            = var.ti_idp_return_sso_token
  bundid_idp_user_import_enabled     = var.bundid_idp_user_import_enabled
  keycloak_user_import_enabled       = var.keycloak_user_import_enabled
  reset_values                       = var.reset_values

  # Secrets and Credentials needed for the applications
  postgres_server_certificate        = var.postgres_server_certificate
  postgres_server_key                = var.postgres_server_key
  postgres_root_ca_certificate       = var.postgres_root_ca_certificate
  root_ca_certificate                = var.root_ca_certificate
  sub_ca_certificate                 = var.sub_ca_certificate
  keycloak_portal_client_secret      = var.keycloak_portal_client_secret
  keycloak_cus_client_secret         = var.keycloak_cus_client_secret
  keycloak_truststore_jks            = var.keycloak_truststore_jks
  keycloak_truststore_password       = var.keycloak_truststore_password
  redis_cus_writer_user              = var.redis_cus_writer_user
  redis_cus_writer_password          = var.redis_cus_writer_password
  redis_cus_reader_user              = var.redis_cus_reader_user
  redis_cus_reader_password          = var.redis_cus_reader_password
  keycloak_admin_user                = var.keycloak_admin_user
  keycloak_admin_password            = var.keycloak_admin_password
  keycloak_portal_admin_user         = var.keycloak_portal_admin_user
  keycloak_portal_admin_password     = var.keycloak_portal_admin_password
  keycloak_portal_client_id          = var.keycloak_portal_client_id
  database_credentials               = var.database_credentials
  cus_health_department_certificates = var.cus_health_department_certificates

  depends_on = [module.persistent_volume_claims, module.pull_secrets, module.activate_maintenance_mode]
}
