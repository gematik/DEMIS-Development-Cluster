# Loki: own module in the loki folder (chart, bucket Job)
locals {
  loki_name = "loki"
  # Enable only if explicitly set (active-versions.yaml), only deployed together with Grafana
  loki_deployment_information = try(var.deployment_information[local.loki_name], { main = { version = "0.0.0" }, enabled = false })
  loki_enabled                = try(local.loki_deployment_information.enabled, false)
}

module "loki" {
  source = "./loki"

  # Only deploy Loki if explicitly enabled AND Grafana is installed
  count = local.loki_enabled && local.grafana_enabled ? 1 : 0

  target_namespace     = var.target_namespace
  loki_version         = coalesce(try(local.loki_deployment_information.canary.version, null), local.loki_deployment_information.main.version)
  loki_helm_repository = var.helm_repository_by_key.loki
  resource_definitions = { loki = try(var.resource_definitions[local.loki_name], {}) }
  # Storage configuration (local filesystem or external S3)
  loki_storage_type          = var.loki_storage_type
  loki_s3_endpoint           = var.loki_s3_endpoint
  loki_s3_region             = var.loki_s3_region
  loki_s3_bucket             = var.loki_s3_bucket
  loki_s3_object_lock_days   = var.loki_s3_object_lock_days
  loki_s3_object_lock_mode   = var.loki_s3_object_lock_mode
  loki_s3_sse_type           = var.loki_s3_sse_type
  loki_s3_sse_kms_key_id     = var.loki_s3_sse_kms_key_id
  loki_s3_force_path_style   = var.loki_s3_force_path_style
  loki_s3_insecure           = var.loki_s3_insecure
  loki_s3_access_key_id      = var.loki_s3_access_key_id
  loki_s3_secret_access_key  = var.loki_s3_secret_access_key
  loki_s3_credentials_secret = one(kubernetes_secret_v1.loki_s3_credentials[*].metadata[0].name)
  loki_volume                = var.loki_volume
  loki_retention_period      = var.loki_retention_period

  # The bucket Job needs the object storage
  depends_on = [module.object_storage_service]
}
