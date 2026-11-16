locals {
  app  = "loki"
  port = 3100

  # Client-facing Service depends on the topology:
  #   - Monolithic:     the single "loki" Service on the Loki HTTP port 3100.
  #   - SimpleScalable: the NGINX "loki-gateway" Service on port 80, which fans out to
  #                     the read/write targets (same URL paths, different host/port).
  service_host = var.loki_deployment_mode == "SimpleScalable" ? "${local.app}-gateway" : local.app
  service_port = var.loki_deployment_mode == "SimpleScalable" ? 80 : local.port
  service_url  = "http://${local.service_host}.${var.target_namespace}:${local.service_port}"

  # Effective per-target replica counts for the SimpleScalable topology. Each target can be
  # scaled independently; when an override is not set it falls back to the shared loki_replicas.
  read_replicas    = coalesce(var.loki_read_replicas, var.loki_replicas)
  write_replicas   = coalesce(var.loki_write_replicas, var.loki_replicas)
  backend_replicas = coalesce(var.loki_backend_replicas, var.loki_replicas)

  # Number of ingesters that must acknowledge a write (capped at 3). The ingesters live in
  # the write target for SimpleScalable and in the single-binary process for Monolithic.
  ingester_replicas  = var.loki_deployment_mode == "SimpleScalable" ? local.write_replicas : var.loki_replicas
  replication_factor = max(1, min(local.ingester_replicas, 3))

  # Inject the S3 credentials as sensitive Helm values (never written into the values
  # file). Only added for S3 storage and only when a static credential is provided
  # (empty credentials fall back to an IAM role / instance profile).
  s3_credentials = var.loki_storage_type == "s3" ? concat(
    var.loki_s3_access_key_id != "" ? [{
      name  = "loki.storage.s3.accessKeyId"
      value = var.loki_s3_access_key_id
    }] : [],
    var.loki_s3_secret_access_key != "" ? [{
      name  = "loki.storage.s3.secretAccessKey"
      value = var.loki_s3_secret_access_key
    }] : []
  ) : []
}

resource "helm_release" "this" {
  name            = local.app
  repository      = var.loki_helm_repository
  chart           = "loki"
  namespace       = var.target_namespace
  version         = var.loki_version
  max_history     = 3
  wait            = true
  lint            = true
  atomic          = true
  wait_for_jobs   = true
  cleanup_on_fail = true

  values = [templatefile("${path.module}/chart-values.tftpl.yaml", {
    deployment_mode     = var.loki_deployment_mode
    storage_type        = var.loki_storage_type
    replication_factor  = local.replication_factor
    replicas            = var.loki_replicas
    read_replicas       = local.read_replicas
    write_replicas      = local.write_replicas
    backend_replicas    = local.backend_replicas
    retention_period    = var.loki_retention_period
    s3_endpoint         = var.loki_s3_endpoint
    s3_region           = var.loki_s3_region
    s3_bucket_chunks    = var.loki_s3_bucket_chunks
    s3_bucket_ruler     = var.loki_s3_bucket_ruler
    s3_bucket_admin     = var.loki_s3_bucket_admin
    s3_force_path_style = var.loki_s3_force_path_style
    s3_insecure         = var.loki_s3_insecure
  })]

  set_sensitive = local.s3_credentials

  lifecycle {
    precondition {
      condition     = var.loki_storage_type != "s3" || (var.loki_s3_endpoint != "" && var.loki_s3_bucket_chunks != "" && var.loki_s3_bucket_ruler != "" && var.loki_s3_bucket_admin != "")
      error_message = "When loki_storage_type is \"s3\" the loki_s3_endpoint and all loki_s3_bucket_* values must be set."
    }
    precondition {
      condition     = var.loki_replicas == 1 || var.loki_storage_type == "s3"
      error_message = "Running more than one Loki replica requires loki_storage_type = \"s3\" (shared object storage)."
    }
    precondition {
      condition     = var.loki_deployment_mode == "Monolithic" || var.loki_storage_type == "s3"
      error_message = "The \"SimpleScalable\" deployment mode requires loki_storage_type = \"s3\" (shared object storage)."
    }
  }
}
