run "loki_valid_version_test" {
  command = plan

  variables {
    loki_version     = "18.5.1"
    target_namespace = "istio-system"
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
    condition     = helm_release.this.namespace == "istio-system"
    error_message = "The Helm release must be installed into the provided namespace."
  }

  assert {
    condition     = output.loki_port == 3100
    error_message = "The Loki port must be 3100."
  }

  assert {
    condition     = output.loki_service_url == "http://loki.istio-system:3100"
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
    condition     = length(helm_release.this.values) == 1
    error_message = "The Helm release must be configured with exactly one values file."
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
    condition     = output.loki_service_url == "http://loki.monitoring:3100"
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
    loki_helm_repository = "not-a-url"
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
    loki_replicas             = 3
    loki_s3_access_key_id     = "AKIAEXAMPLE"
    loki_s3_secret_access_key = "s3cr3t"
    loki_storage_type         = "s3"
    loki_s3_endpoint          = "s3.eu-central-1.amazonaws.com"
    loki_s3_region            = "eu-central-1"
    loki_s3_bucket_chunks     = "loki-chunks"
    loki_s3_bucket_ruler      = "loki-ruler"
    loki_s3_bucket_admin      = "loki-admin"
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
    condition     = strcontains(helm_release.this.values[0], "chunks: loki-chunks")
    error_message = "The S3 chunks bucket must be rendered into the values."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "replicas: 3")
    error_message = "The configured replica count must be rendered."
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

# S3 storage without static credentials (IAM role) must render but set no credentials.
run "loki_s3_without_credentials_test" {
  command = plan

  variables {
    loki_version          = "18.5.1"
    loki_storage_type     = "s3"
    loki_s3_endpoint      = "minio.storage.svc:9000"
    loki_s3_bucket_chunks = "loki"
    loki_s3_bucket_ruler  = "loki"
    loki_s3_bucket_admin  = "loki"
  }

  assert {
    condition     = length(helm_release.this.set_sensitive) == 0
    error_message = "No credentials must be injected when none are provided (IAM role case)."
  }
}

# S3 storage type without endpoint/buckets must fail the precondition.
run "loki_s3_missing_config_test" {
  command = plan

  variables {
    loki_version      = "18.5.1"
    loki_storage_type = "s3"
  }

  expect_failures = [helm_release.this]
}

# More than one replica requires S3 storage (filesystem must fail the precondition).
run "loki_multi_replica_filesystem_test" {
  command = plan

  variables {
    loki_version  = "18.5.1"
    loki_replicas = 2
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

# The default (Monolithic) mode must disable the gateway and the scalable targets.
run "loki_monolithic_targets_test" {
  command = plan

  variables {
    loki_version = "18.5.1"
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "gateway:\n  enabled: false")
    error_message = "Monolithic mode must disable the gateway."
  }

  assert {
    condition     = output.loki_service_url == "http://loki.istio-system:3100"
    error_message = "Monolithic mode must expose the single 'loki' service on port 3100."
  }
}

# SimpleScalable mode must render the scalable topology and route through the gateway.
run "loki_simple_scalable_values_test" {
  command = plan

  variables {
    loki_version          = "18.5.1"
    loki_deployment_mode  = "SimpleScalable"
    loki_replicas         = 3
    loki_storage_type     = "s3"
    loki_s3_endpoint      = "s3.eu-central-1.amazonaws.com"
    loki_s3_bucket_chunks = "loki"
    loki_s3_bucket_ruler  = "loki"
    loki_s3_bucket_admin  = "loki"
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "deploymentMode: SimpleScalable")
    error_message = "The chart values must configure the SimpleScalable deployment mode."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "gateway:\n  enabled: true")
    error_message = "SimpleScalable mode must enable the gateway."
  }

  assert {
    condition     = output.loki_service_url == "http://loki-gateway.istio-system:80"
    error_message = "SimpleScalable mode must route clients through the loki-gateway service on port 80."
  }

  assert {
    condition     = output.loki_port == 80
    error_message = "SimpleScalable mode must expose the gateway port 80."
  }
}

# SimpleScalable mode: per-target replica overrides must be rendered independently.
run "loki_simple_scalable_per_target_replicas_test" {
  command = plan

  variables {
    loki_version          = "18.5.1"
    loki_deployment_mode  = "SimpleScalable"
    loki_replicas         = 2
    loki_read_replicas    = 4
    loki_write_replicas   = 3
    loki_backend_replicas = 1
    loki_storage_type     = "s3"
    loki_s3_endpoint      = "s3.eu-central-1.amazonaws.com"
    loki_s3_bucket_chunks = "loki"
    loki_s3_bucket_ruler  = "loki"
    loki_s3_bucket_admin  = "loki"
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "read:\n  replicas: 4")
    error_message = "The read target must use its own replica override."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "write:\n  replicas: 3")
    error_message = "The write target must use its own replica override."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "backend:\n  replicas: 1")
    error_message = "The backend target must use its own replica override."
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "replication_factor: 3")
    error_message = "The replication factor must follow the write target replica count (capped at 3)."
  }
}

# SimpleScalable mode: unset per-target overrides must fall back to loki_replicas.
run "loki_simple_scalable_replica_fallback_test" {
  command = plan

  variables {
    loki_version          = "18.5.1"
    loki_deployment_mode  = "SimpleScalable"
    loki_replicas         = 2
    loki_storage_type     = "s3"
    loki_s3_endpoint      = "s3.eu-central-1.amazonaws.com"
    loki_s3_bucket_chunks = "loki"
    loki_s3_bucket_ruler  = "loki"
    loki_s3_bucket_admin  = "loki"
  }

  assert {
    condition     = strcontains(helm_release.this.values[0], "read:\n  replicas: 2") && strcontains(helm_release.this.values[0], "write:\n  replicas: 2") && strcontains(helm_release.this.values[0], "backend:\n  replicas: 2")
    error_message = "Unset per-target replicas must fall back to loki_replicas."
  }
}

# SimpleScalable mode requires S3 storage; filesystem must fail the precondition.
run "loki_simple_scalable_filesystem_test" {
  command = plan

  variables {
    loki_version         = "18.5.1"
    loki_deployment_mode = "SimpleScalable"
  }

  expect_failures = [helm_release.this]
}

# An unknown deployment mode must fail validation.
run "loki_invalid_deployment_mode_test" {
  command = plan

  variables {
    loki_version         = "18.5.1"
    loki_deployment_mode = "Distributed"
  }

  expect_failures = [var.loki_deployment_mode]
}
