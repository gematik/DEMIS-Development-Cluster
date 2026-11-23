# Offline: no chart download and no cluster, the asserted values all come from the configuration
mock_provider "helm" {}
mock_provider "kubernetes" {}

run "loki_valid_version_test" {
  command = plan

  variables {
    loki_version     = "18.5.1"
    target_namespace = "observability"
  }

  assert {
    condition     = helm_release.this.name == "loki"
    error_message = "The Helm release name must be 'loki'."
  }

  assert {
    condition     = helm_release.this.chart == "loki"
    error_message = "The Helm chart must be 'loki'."
  }

  assert {
    condition     = helm_release.this.version == "18.5.1"
    error_message = "The Loki version must match the provided version."
  }

  assert {
    condition     = helm_release.this.namespace == "observability"
    error_message = "The Helm release must be installed into the provided namespace."
  }

  assert {
    condition     = output.loki_port == 3100
    error_message = "The Loki port must be 3100."
  }

  assert {
    condition     = output.loki_service_url == "http://loki.observability.svc.cluster.local:3100"
    error_message = "The Loki service URL must be built from app name, namespace and port."
  }
}

# Ensure the default Helm repository is the grafana-community OCI charts repository.
run "loki_default_helm_repository_test" {
  command = plan

  variables {
    loki_version = "18.5.1"
  }

  assert {
    condition     = helm_release.this.repository == "oci://ghcr.io/grafana-community/helm-charts"
    error_message = "The default Loki Helm repository must be the grafana-community OCI helm-charts repository."
  }
}

# Ensure the operational safety settings of the Helm release are enforced.
run "loki_helm_release_safety_settings_test" {
  command = plan

  variables {
    loki_version = "18.5.1"
  }

  assert {
    condition     = helm_release.this.atomic == true
    error_message = "The Helm release must be atomic."
  }

  assert {
    condition     = helm_release.this.cleanup_on_fail == true
    error_message = "The Helm release must clean up on failure."
  }

  assert {
    condition     = helm_release.this.wait == true
    error_message = "The Helm release must wait for readiness."
  }

  assert {
    condition     = helm_release.this.max_history == 3
    error_message = "The Helm release must keep a bounded history of 3 revisions."
  }

  assert {
    condition     = length(helm_release.this.values) == 2
    error_message = "The Helm release must get the chart values and the resource values."
  }
}

# The single-binary values file must actually be single-binary with filesystem storage.
run "loki_chart_values_single_binary_test" {
  command = plan

  variables {
    loki_version = "18.5.1"
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "deploymentMode: Monolithic")
    error_message = "The chart values must configure the single-binary deployment mode."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "type: filesystem")
    error_message = "The chart values must configure filesystem storage."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "auth_enabled: false")
    error_message = "The chart values must disable multi-tenancy auth."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "fullnameOverride: loki")
    error_message = "The chart values must pin the fullname to 'loki' so the service is reachable at http://loki:3100."
  }
}

# The service URL must honour a custom target namespace.
run "loki_custom_namespace_service_url_test" {
  command = plan

  variables {
    loki_version     = "18.5.1"
    target_namespace = "monitoring"
  }

  assert {
    condition     = output.loki_service_url == "http://loki.monitoring.svc.cluster.local:3100"
    error_message = "The Loki service URL must reflect the configured target namespace."
  }
}

run "loki_invalid_version_test" {
  command = plan

  variables {
    loki_version = "not-a-version"
  }

  expect_failures = [var.loki_version]
}

# A leading 'v' is not a valid bare semantic version for the chart.
run "loki_invalid_version_with_prefix_test" {
  command = plan

  variables {
    loki_version = "v18.5.1"
  }

  expect_failures = [var.loki_version]
}

run "loki_invalid_helm_repository_test" {
  command = plan

  variables {
    loki_version         = "18.5.1"
    loki_helm_repository = "not a url or repository name"
  }

  expect_failures = [var.loki_helm_repository]
}

# Default (filesystem) storage must render filesystem storage and object_store.
run "loki_filesystem_storage_values_test" {
  command = plan

  variables {
    loki_version = "18.5.1"
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "type: filesystem")
    error_message = "Default storage must be filesystem."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "object_store: filesystem")
    error_message = "Default schema object_store must be filesystem."
  }

  assert {
    condition     = length(helm_release.this.set_sensitive) == 0
    error_message = "No sensitive S3 credentials must be set for filesystem storage."
  }
}

# S3 storage must render the S3 block and inject the credentials via set_sensitive.
run "loki_s3_storage_values_test" {
  command = plan

  variables {
    loki_version              = "18.5.1"
    resource_definitions      = { loki = { replicas = 3 } }
    loki_s3_access_key_id     = "AKIAEXAMPLE"
    loki_s3_secret_access_key = "s3cr3t"
    loki_storage_type         = "s3"
    loki_s3_endpoint          = "s3.eu-central-1.amazonaws.com"
    loki_s3_region            = "eu-central-1"
    loki_s3_bucket            = "loki-chunks"
    loki_s3_force_path_style  = false
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "type: s3")
    error_message = "S3 storage type must be rendered."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "object_store: s3")
    error_message = "Schema object_store must be s3."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "endpoint: s3.eu-central-1.amazonaws.com")
    error_message = "The S3 endpoint must be rendered into the values."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "chunks: loki-chunks") && strcontains(helm_release.this.values[0], "admin: loki-chunks")
    error_message = "The own S3 bucket must be rendered for chunks, ruler and admin."
  }

  assert {
    condition     = yamldecode(helm_release.this.values[0]).singleBinary.replicas == 3
    error_message = "The configured replica count must be rendered."
  }

  assert {
    condition     = yamldecode(helm_release.this.values[0]).loki.commonConfig.replication_factor == 3
    error_message = "Every write must be acknowledged by 3 instances."
  }

  assert {
    condition     = length(helm_release.this.set_sensitive) == 2
    error_message = "Both S3 credentials must be injected as sensitive Helm values."
  }

  assert {
    condition     = !strcontains(helm_release.this.values[0], "s3cr3t")
    error_message = "The S3 secret must never be written into the values file."
  }
}

# S3 storage without static credentials cannot create the own bucket.
run "loki_s3_without_credentials_test" {
  command = plan

  variables {
    loki_version      = "18.5.1"
    loki_storage_type = "s3"
    loki_s3_endpoint  = "minio.storage.svc:9000"
  }

  expect_failures = [kubernetes_job_v1.bucket]
}

# S3 storage type without endpoint must fail the precondition.
run "loki_s3_missing_config_test" {
  command = plan

  variables {
    loki_version              = "18.5.1"
    loki_storage_type         = "s3"
    loki_s3_access_key_id     = "loki-key"
    loki_s3_secret_access_key = "loki-secret" # checkov:skip=CKV_SECRET_6: dummy value of the unit test
  }

  expect_failures = [helm_release.this]
}

# More than one replica requires S3 storage (filesystem must fail the precondition).
run "loki_multi_replica_filesystem_test" {
  command = plan

  variables {
    loki_version         = "18.5.1"
    resource_definitions = { loki = { replicas = 2 } }
  }

  expect_failures = [helm_release.this]
}

# Invalid retention period must fail validation.
run "loki_invalid_retention_test" {
  command = plan

  variables {
    loki_version          = "18.5.1"
    loki_retention_period = "seven-days"
  }

  expect_failures = [var.loki_retention_period]
}

# Only the monolithic target runs, without gateway.
run "loki_monolithic_targets_test" {
  command = plan

  variables {
    loki_version = "18.5.1"
  }

  assert {
    condition     = [for t in ["read", "write", "backend"] : yamldecode(helm_release.this.values[0])[t].replicas] == [0, 0, 0] && yamldecode(helm_release.this.values[0]).deploymentMode == "Monolithic"
    error_message = "Only the monolithic target must be deployed."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "gateway:\n  enabled: false")
    error_message = "The gateway must be disabled."
  }

  assert {
    condition     = output.loki_service_url == "http://loki.observability.svc.cluster.local:3100"
    error_message = "The clients must use the 'loki' service on port 3100."
  }
}

# S3 storage with object lock and SSE-S3 (requirements of the object-storage-service setup).
run "loki_s3_object_lock_sse_test" {
  command = plan

  variables {
    loki_version              = "18.5.1"
    loki_storage_type         = "s3"
    loki_s3_endpoint          = "object-storage-service.demis.svc.cluster.local:8080"
    loki_s3_insecure          = true
    loki_s3_access_key_id     = "loki-key"
    loki_s3_secret_access_key = "loki-secret" # checkov:skip=CKV_SECRET_6: dummy value of the unit test
    loki_s3_object_lock_days  = 183
    loki_s3_sse_type          = "SSE-S3"
    loki_retention_period     = "4392h"
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "sse:\n        type: SSE-S3")
    error_message = "SSE-S3 must be rendered into the S3 storage config."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "retention_period: 4392h") && strcontains(helm_release.this.values[0], "retention_enabled: true") && strcontains(helm_release.this.values[0], "delete_request_store: s3")
    error_message = "The compactor must apply the retention period."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "gateway:\n  enabled: false") && output.loki_service_url == "http://loki.observability.svc.cluster.local:3100"
    error_message = "With S3 the clients must use the 'loki' service as well, without gateway."
  }

  assert {
    condition     = contains([for e in kubernetes_job_v1.bucket[0].spec[0].template[0].spec[0].container[0].env : "${e.name}=${e.value}"], "LOCK_DAYS=183") && contains([for e in kubernetes_job_v1.bucket[0].spec[0].template[0].spec[0].container[0].env : "${e.name}=${e.value}"], "LOCK_MODE=COMPLIANCE") && contains([for e in kubernetes_job_v1.bucket[0].spec[0].template[0].spec[0].container[0].env : "${e.name}=${e.value}"], "SSE_TYPE=SSE-S3")
    error_message = "The bucket Job must create the bucket with object lock (COMPLIANCE by default) and SSE-S3."
  }

  assert {
    condition     = contains([for e in kubernetes_job_v1.bucket[0].spec[0].template[0].spec[0].container[0].env : "${e.name}=${e.value}"], "S3_ENDPOINT=http://object-storage-service.demis.svc.cluster.local:8080")
    error_message = "The bucket Job must use plain HTTP for an insecure endpoint."
  }

  assert {
    condition     = startswith(kubernetes_job_v1.bucket[0].spec[0].template[0].spec[0].service_account_name, "loki")
    error_message = "The bucket Job service account must match the loki* principal allowed at the object-storage-service."
  }
}

# Default (filesystem) storage must not create the bucket Job.
run "loki_filesystem_no_bucket_job_test" {
  command = plan

  variables {
    loki_version = "18.5.1"
  }

  assert {
    condition     = length(kubernetes_job_v1.bucket) == 0
    error_message = "Filesystem storage must not create the bucket Job."
  }
}

# The object lock must not outlast the retention period.
run "loki_object_lock_exceeds_retention_test" {
  command = plan

  variables {
    loki_version              = "18.5.1"
    loki_storage_type         = "s3"
    loki_s3_endpoint          = "object-storage-service.demis.svc.cluster.local:8080"
    loki_s3_access_key_id     = "loki-key"
    loki_s3_secret_access_key = "loki-secret" # checkov:skip=CKV_SECRET_6: dummy value of the unit test
    loki_s3_object_lock_days  = 30
    loki_retention_period     = "168h"
  }

  expect_failures = [helm_release.this]
}

# Filesystem storage has no object lock: a short retention needs no loki_s3_object_lock_days.
run "loki_filesystem_short_retention_test" {
  command = plan

  variables {
    loki_version          = "18.5.1"
    loki_retention_period = "720h"
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "retention_period: 720h")
    error_message = "The retention must be rendered without an object lock check."
  }
}

# Invalid bucket names and negative lock days must fail validation.
run "loki_invalid_bucket_settings_test" {
  command = plan

  variables {
    loki_version             = "18.5.1"
    loki_s3_bucket           = "Loki_Bucket"
    loki_s3_object_lock_days = -1
    loki_s3_object_lock_mode = "LEGAL_HOLD"
  }

  expect_failures = [var.loki_s3_bucket, var.loki_s3_object_lock_days, var.loki_s3_object_lock_mode]
}

# Encryption switched off: no sse in the storage config, the bucket Job removes the default encryption.
run "loki_s3_sse_none_test" {
  command = plan

  variables {
    loki_version              = "18.5.1"
    loki_storage_type         = "s3"
    loki_s3_endpoint          = "object-storage-service.observability.svc.cluster.local:8080"
    loki_s3_access_key_id     = "loki-key"
    loki_s3_secret_access_key = "loki-secret" # checkov:skip=CKV_SECRET_6: dummy value of the unit test
    loki_s3_sse_type          = "none"
  }

  assert {
    condition     = !strcontains(helm_release.this.values[0], "sse:")
    error_message = "Without encryption no sse must be rendered."
  }

  assert {
    condition     = contains([for e in kubernetes_job_v1.bucket[0].spec[0].template[0].spec[0].container[0].env : "${e.name}=${e.value}"], "SSE_TYPE=none")
    error_message = "The bucket Job must get the encryption type none."
  }
}

# SSE-KMS renders the type and the key id and hands both to the bucket Job.
run "loki_s3_sse_kms_test" {
  command = plan

  variables {
    loki_version              = "18.5.1"
    loki_storage_type         = "s3"
    loki_s3_endpoint          = "s3.example.internal:443"
    loki_s3_access_key_id     = "loki-key"
    loki_s3_secret_access_key = "loki-secret" # checkov:skip=CKV_SECRET_6: dummy value of the unit test
    loki_s3_sse_type          = "SSE-KMS"
    loki_s3_sse_kms_key_id    = "loki-key-1"
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "sse:\n        type: SSE-KMS\n        kms_key_id: loki-key-1")
    error_message = "SSE-KMS must be rendered with its key id."
  }

  assert {
    condition     = contains([for e in kubernetes_job_v1.bucket[0].spec[0].template[0].spec[0].container[0].env : "${e.name}=${e.value}"], "SSE_TYPE=SSE-KMS") && contains([for e in kubernetes_job_v1.bucket[0].spec[0].template[0].spec[0].container[0].env : "${e.name}=${e.value}"], "KMS_KEY_ID=loki-key-1")
    error_message = "The bucket Job must set the KMS default encryption with the key id."
  }
}

run "loki_s3_sse_kms_without_key_test" {
  command = plan

  variables {
    loki_version              = "18.5.1"
    loki_storage_type         = "s3"
    loki_s3_endpoint          = "s3.example.internal:443"
    loki_s3_access_key_id     = "loki-key"
    loki_s3_secret_access_key = "loki-secret" # checkov:skip=CKV_SECRET_6: dummy value of the unit test
    loki_s3_sse_type          = "SSE-KMS"
  }

  expect_failures = [helm_release.this]
}

run "loki_s3_sse_invalid_type_test" {
  command = plan

  variables {
    loki_version     = "18.5.1"
    loki_s3_sse_type = "sse-c"
  }

  expect_failures = [var.loki_s3_sse_type]
}

# Without loki_volume the instances have no PVC.
run "loki_volume_default_test" {
  command = plan

  variables {
    loki_version = "18.5.1"
  }

  assert {
    condition     = yamldecode(helm_release.this.values[0]).singleBinary.persistence.enabled == false
    error_message = "Without loki_volume no PVC must be requested."
  }
}

# loki_volume requests a PVC per instance with the given class and size.
run "loki_volume_test" {
  command = plan

  variables {
    loki_version = "18.5.1"
    loki_volume = {
      storage_class = "standard"
      capacity      = "10Gi"
    }
  }

  assert {
    condition = yamldecode(helm_release.this.values[0]).singleBinary.persistence == {
      enabled      = true
      storageClass = "standard"
      size         = "10Gi"
    }
    error_message = "loki_volume must render an enabled PVC with storage class and size."
  }
}

# Without replicas: 3 instances with S3, 1 with filesystem.
run "loki_default_replicas_s3_test" {
  command = plan

  variables {
    loki_version              = "18.5.1"
    loki_storage_type         = "s3"
    loki_s3_endpoint          = "object-storage-service.observability.svc.cluster.local:8080"
    loki_s3_access_key_id     = "loki-key"
    loki_s3_secret_access_key = "loki-secret" # checkov:skip=CKV_SECRET_6: dummy value of the unit test
  }

  assert {
    condition     = yamldecode(helm_release.this.values[0]).singleBinary.replicas == 3 && yamldecode(helm_release.this.values[0]).loki.commonConfig.replication_factor == 3
    error_message = "With S3 the default must be 3 instances with replication factor 3."
  }
}

run "loki_default_replicas_filesystem_test" {
  command = plan

  variables {
    loki_version = "18.5.1"
  }

  assert {
    condition     = yamldecode(helm_release.this.values[0]).singleBinary.replicas == 1 && yamldecode(helm_release.this.values[0]).loki.commonConfig.replication_factor == 1
    error_message = "With filesystem the default must be one instance."
  }
}

# resources.tfvars (output of the resources module): resources and sidecar resources of Loki are merged into the chart values.
run "loki_resource_definitions_test" {
  command = plan

  variables {
    loki_version = "18.5.1"
    resource_definitions = {
      loki = {
        resource_block = yamlencode({ resources = { requests = { cpu = "100m", memory = "512Mi" } } })
        istio_proxy_resources = {
          limits   = { memory = "256Mi" }
          requests = { cpu = "10m", memory = "64Mi" }
        }
      }
    }
  }

  assert {
    condition     = yamldecode(helm_release.this.values[1]).singleBinary.resources.requests.memory == "512Mi" && yamldecode(helm_release.this.values[1]).singleBinary.podAnnotations["sidecar.istio.io/proxyCPU"] == "10m"
    error_message = "Resources and sidecar annotations of Loki must be rendered."
  }

  assert {
    condition     = !can(yamldecode(helm_release.this.values[1]).singleBinary.resources.limits)
    error_message = "Only the set values must be rendered."
  }
}
