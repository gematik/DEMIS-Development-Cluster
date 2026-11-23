locals {
  bucket_job_enabled = var.loki_storage_type == "s3"
  # Service account name matches the "loki*" principal allowed to access the object-storage-service
  bucket_job_name = "${local.app}-bucket"
  s3_endpoint_url = "${var.loki_s3_insecure ? "http" : "https"}://${var.loki_s3_endpoint}"

  # Creates the own Loki bucket once and (re)applies its configuration (documented in the script)
  bucket_script = file("${path.module}/config/bucket.sh")
}

resource "kubernetes_service_account_v1" "bucket" {
  count = local.bucket_job_enabled ? 1 : 0
  metadata {
    name      = local.bucket_job_name
    namespace = var.target_namespace
  }
  automount_service_account_token = false
}

resource "kubernetes_job_v1" "bucket" {
  count = local.bucket_job_enabled ? 1 : 0
  metadata {
    # A changed bucket configuration creates a new Job
    name      = "${local.bucket_job_name}-${substr(sha256(jsonencode([var.loki_s3_bucket, var.loki_s3_object_lock_days, var.loki_s3_object_lock_mode, var.loki_s3_sse_type, var.loki_s3_sse_kms_key_id, local.bucket_script])), 0, 8)}"
    namespace = var.target_namespace
  }
  spec {
    backoff_limit = 6
    template {
      metadata {
        labels = {
          app                       = local.bucket_job_name
          "sidecar.istio.io/inject" = "true"
        }
      }
      spec {
        service_account_name = kubernetes_service_account_v1.bucket[0].metadata[0].name
        restart_policy       = "Never"
        container {
          name    = "bucket"
          image   = var.loki_bucket_job_image
          command = ["/bin/sh", "-c", local.bucket_script]
          env {
            name  = "S3_ENDPOINT"
            value = local.s3_endpoint_url
          }
          env {
            # aws-cli writes its cache to $HOME, not writable for the non-root user
            name  = "HOME"
            value = "/tmp"
          }
          env {
            name  = "AWS_DEFAULT_REGION"
            value = coalesce(var.loki_s3_region, "us-east-1")
          }
          env {
            name  = "BUCKET"
            value = var.loki_s3_bucket
          }
          env {
            name  = "LOCK_DAYS"
            value = tostring(var.loki_s3_object_lock_days)
          }
          env {
            name  = "LOCK_MODE"
            value = var.loki_s3_object_lock_mode
          }
          env {
            name  = "SSE_TYPE"
            value = var.loki_s3_sse_type
          }
          env {
            name  = "KMS_KEY_ID"
            value = var.loki_s3_sse_kms_key_id
          }
          env {
            name  = "AWS_SHARED_CREDENTIALS_FILE"
            value = "/run/secrets/loki-s3/credentials"
          }
          volume_mount {
            name       = "credentials"
            mount_path = "/run/secrets/loki-s3"
            read_only  = true
          }
          security_context {
            allow_privilege_escalation = false
            run_as_non_root            = true
            run_as_user                = 1000
          }
        }
        volume {
          name = "credentials"
          secret {
            secret_name = var.loki_s3_credentials_secret
          }
        }
      }
    }
  }
  wait_for_completion = true
  timeouts {
    create = "5m"
    update = "5m"
  }

  lifecycle {
    precondition {
      condition     = var.loki_s3_access_key_id != "" && var.loki_s3_secret_access_key != ""
      error_message = "Creating the Loki bucket requires loki_s3_access_key_id and loki_s3_secret_access_key."
    }
  }
}

