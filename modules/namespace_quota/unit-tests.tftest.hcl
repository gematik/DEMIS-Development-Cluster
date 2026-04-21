provider "kubernetes" {
  config_path = "testdata/.test_kubeconfig"
}

# Test: ResourceQuota is created with CPU and Memory Limits
run "quota_with_limits_test" {
  command = plan

  variables {
    namespace = "demis"
    resource_quota = {
      limits_cpu    = "4"
      limits_memory = "8Gi"
    }
  }

  # assert that the ResourceQuota is created
  assert {
    condition     = length(kubernetes_resource_quota_v1.this) == 1
    error_message = "The ResourceQuota should be created when resource_quota is provided."
  }

  # assert that the ResourceQuota has the correct name
  assert {
    condition     = kubernetes_resource_quota_v1.this[0].metadata[0].name == "demis-quota"
    error_message = "The ResourceQuota name should be 'demis-quota'."
  }

  # assert that the ResourceQuota is in the correct namespace
  assert {
    condition     = kubernetes_resource_quota_v1.this[0].metadata[0].namespace == "demis"
    error_message = "The ResourceQuota should be in the 'demis' namespace."
  }

  # assert that limits.cpu is set correctly
  assert {
    condition     = kubernetes_resource_quota_v1.this[0].spec[0].hard["limits.cpu"] == "4"
    error_message = "The CPU limit should be '4'."
  }

  # assert that limits.memory is set correctly
  assert {
    condition     = kubernetes_resource_quota_v1.this[0].spec[0].hard["limits.memory"] == "8Gi"
    error_message = "The memory limit should be '8Gi'."
  }

  # assert that output is correct
  assert {
    condition     = output.resource_quota_name == "demis-quota"
    error_message = "The output resource_quota_name should be 'demis-quota'."
  }
}

# Test: ResourceQuota is created with all fields (limits and requests)
run "quota_with_all_fields_test" {
  command = plan

  variables {
    namespace = "test-ns"
    resource_quota = {
      limits_cpu      = "8"
      limits_memory   = "16Gi"
      requests_cpu    = "4"
      requests_memory = "8Gi"
    }
  }

  # assert that the ResourceQuota is created
  assert {
    condition     = length(kubernetes_resource_quota_v1.this) == 1
    error_message = "The ResourceQuota should be created when resource_quota is provided."
  }

  # assert that the ResourceQuota has the correct name
  assert {
    condition     = kubernetes_resource_quota_v1.this[0].metadata[0].name == "test-ns-quota"
    error_message = "The ResourceQuota name should be 'test-ns-quota'."
  }

  # assert that limits.cpu is set correctly
  assert {
    condition     = kubernetes_resource_quota_v1.this[0].spec[0].hard["limits.cpu"] == "8"
    error_message = "The CPU limit should be '8'."
  }

  # assert that limits.memory is set correctly
  assert {
    condition     = kubernetes_resource_quota_v1.this[0].spec[0].hard["limits.memory"] == "16Gi"
    error_message = "The memory limit should be '16Gi'."
  }

  # assert that requests.cpu is set correctly
  assert {
    condition     = kubernetes_resource_quota_v1.this[0].spec[0].hard["requests.cpu"] == "4"
    error_message = "The CPU request should be '4'."
  }

  # assert that requests.memory is set correctly
  assert {
    condition     = kubernetes_resource_quota_v1.this[0].spec[0].hard["requests.memory"] == "8Gi"
    error_message = "The memory request should be '8Gi'."
  }

  # assert that output is correct
  assert {
    condition     = output.resource_quota_name == "test-ns-quota"
    error_message = "The output resource_quota_name should be 'test-ns-quota'."
  }
}

# Test: No ResourceQuota is created when resource_quota is null
run "quota_null_test" {
  command = plan

  variables {
    namespace      = "mesh"
    resource_quota = null
  }

  # assert that no ResourceQuota is created
  assert {
    condition     = length(kubernetes_resource_quota_v1.this) == 0
    error_message = "No ResourceQuota should be created when resource_quota is null."
  }

  # assert that output is null
  assert {
    condition     = output.resource_quota_name == null
    error_message = "The output resource_quota_name should be null when no quota is created."
  }
}

# Test: ResourceQuota with only CPU limit
run "quota_cpu_only_test" {
  command = plan

  variables {
    namespace = "are"
    resource_quota = {
      limits_cpu = "2"
    }
  }

  # assert that the ResourceQuota is created
  assert {
    condition     = length(kubernetes_resource_quota_v1.this) == 1
    error_message = "The ResourceQuota should be created when resource_quota is provided."
  }

  # assert that limits.cpu is set correctly
  assert {
    condition     = kubernetes_resource_quota_v1.this[0].spec[0].hard["limits.cpu"] == "2"
    error_message = "The CPU limit should be '2'."
  }

  # assert that limits.memory is not set
  assert {
    condition     = !contains(keys(kubernetes_resource_quota_v1.this[0].spec[0].hard), "limits.memory")
    error_message = "The memory limit should not be set when only CPU limit is provided."
  }
}

# Test: ResourceQuota with only memory limit
run "quota_memory_only_test" {
  command = plan

  variables {
    namespace = "dmz"
    resource_quota = {
      limits_memory = "4Gi"
    }
  }

  # assert that the ResourceQuota is created
  assert {
    condition     = length(kubernetes_resource_quota_v1.this) == 1
    error_message = "The ResourceQuota should be created when resource_quota is provided."
  }

  # assert that limits.memory is set correctly
  assert {
    condition     = kubernetes_resource_quota_v1.this[0].spec[0].hard["limits.memory"] == "4Gi"
    error_message = "The memory limit should be '4Gi'."
  }

  # assert that limits.cpu is not set
  assert {
    condition     = !contains(keys(kubernetes_resource_quota_v1.this[0].spec[0].hard), "limits.cpu")
    error_message = "The CPU limit should not be set when only memory limit is provided."
  }
}
