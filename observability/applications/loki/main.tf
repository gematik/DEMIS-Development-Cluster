locals {
  app  = "loki"
  port = 3100

  # No gateway: the clients reach the "loki" Service directly, who may push or query is set by the
  # Istio authorization policies of the namespace (policies chart)
  service_url = "http://${local.app}.${var.target_namespace}.svc.cluster.local:${local.port}"

  # Replicas, resources and sidecar annotations of Loki (resources.tfvars)
  workloads = {
    for name in ["loki"] : name => {
      replicas  = try(var.resource_definitions[name].replicas, null)
      resources = try(yamldecode(var.resource_definitions[name].resource_block).resources, null)
      annotations = try({
        "sidecar.istio.io/proxyCPU"         = var.resource_definitions[name].istio_proxy_resources.requests.cpu
        "sidecar.istio.io/proxyMemory"      = var.resource_definitions[name].istio_proxy_resources.requests.memory
        "sidecar.istio.io/proxyMemoryLimit" = var.resource_definitions[name].istio_proxy_resources.limits.memory
      }, {})
    }
  }
  # 3 instances with S3 by default, the filesystem storage allows only one
  replicas = coalesce(local.workloads.loki.replicas, var.loki_storage_type == "s3" ? 3 : 1)
  # Merged into the chart values (unset values keep the defaults)
  resource_values = {
    singleBinary = { for k, v in {
      resources      = local.workloads.loki.resources
      podAnnotations = local.workloads.loki.annotations
    } : k => v if v != null }
  }
  # Number of instances that must acknowledge a write (capped at 3)
  replication_factor = max(1, min(local.replicas, 3))

  # Retention in hours, to compare it with the object lock days
  retention_unit_hours = { s = 1 / 3600, m = 1 / 60, h = 1, d = 24 }
  retention_hours      = tonumber(regex("^[0-9]+", var.loki_retention_period)) * local.retention_unit_hours[regex("[smhd]$", var.loki_retention_period)]

  # Inject the S3 credentials as sensitive Helm values (never written into the values
  # file). Only added for S3 storage and only when a static credential is provided
  # (empty credentials fall back to an IAM role / instance profile).
  s3_credentials = var.loki_storage_type == "s3" ? concat(
    var.loki_s3_access_key_id != "" ? [{
      name  = "loki.storage.s3.accessKeyId"
      value = var.loki_s3_access_key_id
      type  = "string"
    }] : [],
    var.loki_s3_secret_access_key != "" ? [{
      name  = "loki.storage.s3.secretAccessKey"
      value = var.loki_s3_secret_access_key
      type  = "string"
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

  values = [templatefile("${path.module}/config/chart-values.tftpl.yaml", {
    storage_type        = var.loki_storage_type
    replication_factor  = local.replication_factor
    replicas            = local.replicas
    volume              = var.loki_volume
    retention_period    = var.loki_retention_period
    s3_endpoint         = var.loki_s3_endpoint
    s3_region           = var.loki_s3_region
    s3_bucket           = var.loki_s3_bucket
    s3_force_path_style = var.loki_s3_force_path_style
    s3_insecure         = var.loki_s3_insecure
    s3_sse_type         = var.loki_s3_sse_type
    s3_sse_kms_key_id   = var.loki_s3_sse_kms_key_id
  }), yamlencode(local.resource_values)]

  set_sensitive = local.s3_credentials

  # The bucket (object lock, encryption) must exist before Loki writes to it
  depends_on = [kubernetes_job_v1.bucket]

  lifecycle {
    precondition {
      condition     = var.loki_storage_type != "s3" || (var.loki_s3_endpoint != "" && var.loki_s3_bucket != "")
      error_message = "When loki_storage_type is \"s3\" the loki_s3_endpoint and loki_s3_bucket must be set."
    }
    precondition {
      condition     = local.replicas == 1 || var.loki_storage_type == "s3"
      error_message = "Running more than one Loki replica requires loki_storage_type = \"s3\" (shared object storage)."
    }
    precondition {
      condition     = var.loki_s3_sse_type != "SSE-KMS" || var.loki_s3_sse_kms_key_id != ""
      error_message = "loki_s3_sse_type = \"SSE-KMS\" requires loki_s3_sse_kms_key_id."
    }
    precondition {
      # Only the S3 bucket has an object lock
      condition     = var.loki_storage_type != "s3" || var.loki_s3_object_lock_days * 24 <= local.retention_hours
      error_message = "The object lock (loki_s3_object_lock_days) must not outlast loki_retention_period."
    }
  }
}
