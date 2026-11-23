########################
# Components of the observability namespace (as demis/applications.tf)
########################

module "observability_services" {
  source = "./applications"

  # Namespaces, charts and images
  target_namespace = local.namespace
  # Without the observability namespace (project feature flag) no component is deployed
  deployment_information         = { for name, info in local.deployment_information : name => info if local.namespace_enabled }
  helm_repository_by_key         = local.helm_repository_by_key
  demis_helm_repository          = local.demis_helm_repository
  demis_helm_repository_username = local.demis_helm_repository_username
  demis_helm_repository_password = local.demis_helm_repository_password
  docker_registry                = var.docker_registry
  external_chart_path            = local.chart_source_path
  pull_secrets                   = [for k, v in module.pull_secrets : v.metadata.name]
  volume_claims                  = { for k, v in module.persistent_volume_claims : k => v.metadata.name }
  # Thread the maintenance-mode status as explicit input instead of using depends_on.
  # This establishes the apply-time ordering (activate → deploy) through data-flow,
  # which avoids the "known after apply" propagation that module-level depends_on causes.
  maintenance_mode_trigger = module.activate_maintenance_mode.maintenance_mode_status

  # Project feature flags, as in the demis module
  project_feature_flags = var.project_feature_flags

  # Feature flags, config options, resources and timeouts/retries of the workloads
  feature_flags           = module.application_flags.service_feature_flags
  config_options          = module.application_flags.service_config_options
  resource_definitions    = module.application_resources.service_resource_definitions
  timeout_retry_overrides = var.timeout_retry_overrides

  # Loki
  loki_storage_type        = var.loki_storage_type
  loki_s3_endpoint         = var.loki_s3_endpoint
  loki_s3_region           = var.loki_s3_region
  loki_s3_bucket           = var.loki_s3_bucket
  loki_s3_force_path_style = var.loki_s3_force_path_style
  loki_s3_insecure         = var.loki_s3_insecure
  loki_s3_object_lock_days = var.loki_s3_object_lock_days
  loki_s3_object_lock_mode = var.loki_s3_object_lock_mode
  loki_s3_sse_type         = var.loki_s3_sse_type
  loki_s3_sse_kms_key_id   = var.loki_s3_sse_kms_key_id
  loki_volume              = var.loki_volume
  loki_retention_period    = var.loki_retention_period

  # Kiali: URLs of Prometheus, Tracing and Grafana set from outside
  prometheus_service_url = var.prometheus_service_url
  tracing_service_url    = var.tracing_service_url
  tracing_service_port   = var.tracing_service_port
  grafana_service_url    = var.grafana_service_url
  grafana_public_url     = var.grafana_public_url

  # Jaeger
  jaeger_max_traces      = var.jaeger_max_traces
  jaeger_ttl_spans       = var.jaeger_ttl_spans
  jaeger_storage_backend = var.jaeger_storage_backend

  # Audit Log Service
  audit_log_service_audited_namespaces = var.audit_log_service_audited_namespaces

  # Remote debugging of the Java services (Audit Log Service and Purger)
  debug_enabled = var.debug_enabled

  # Audit Log Purger
  audit_log_purger_suspend       = var.audit_log_purger_suspend
  audit_log_purger_cron_schedule = var.audit_log_purger_cron_schedule

  # Secrets and Credentials needed for the applications
  database_credentials                  = var.database_credentials
  postgres_server_key                   = var.postgres_server_key
  postgres_server_certificate           = var.postgres_server_certificate
  postgres_root_ca_certificate          = var.postgres_root_ca_certificate
  object_storage_service_access_key     = var.object_storage_service_access_key
  object_storage_service_secret_key     = var.object_storage_service_secret_key
  object_storage_service_sse_passphrase = var.object_storage_service_sse_passphrase
  loki_s3_access_key_id                 = var.loki_s3_access_key_id
  loki_s3_secret_access_key             = var.loki_s3_secret_access_key
}
