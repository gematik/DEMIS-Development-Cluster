# Test no Resource Definitions
run "no_resource_definitions_test" {
  command = plan

  variables {
    resource_definitions = []
  }

  assert {
    condition     = length(output.service_resource_definitions) == 0
    error_message = "The output is not empty."
  }
}

# Test Resource Definitions with invalid service name value
run "resource_definitions_expect_failure_no_valid_servicename_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service = "",
        resources = {
          limits   = { cpu = "200m", memory = "256Mi" },
          requests = { cpu = "100m", memory = "128Mi" }
        },
        replicas = 1
      }
    ]
  }

  expect_failures = [var.resource_definitions]
}

# Test Resource Definitions with a single service having no replicas defined
run "resource_definitions_single_service_no_replicas_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service  = "service1",
        replicas = -1,
        resources = {
          limits   = { cpu = "200m", memory = "256Mi" },
          requests = { cpu = "100m", memory = "128Mi" }
        }
      }
    ]
  }

  expect_failures = [var.resource_definitions]
}

# Test Resource Definitions with a single service
run "resource_definitions_single_service_complete_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service = "service1",
        resources = {
          limits   = { cpu = "200m", memory = "256Mi" },
          requests = { cpu = "100m", memory = "128Mi" }
        },
        replicas = 1
      }
    ]
  }

  assert {
    condition     = length(output.service_resource_definitions) == 1
    error_message = "The output does not contain service1."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].replicas == 1
    error_message = "The output does not contain the correct number of replicas."
  }

  assert {
    condition     = lookup(output.service_resource_definitions, "service1", {}) != {}
    error_message = "The output does not contain the correct service1 entry."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block) != null
    error_message = "The output does not contain the correct resource block."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits.cpu == "200m"
    error_message = "The expected CPU limits does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests.cpu == "100m"
    error_message = "The expected CPU requests does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits.memory == "256Mi"
    error_message = "The expected Memory limits does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests.memory == "128Mi"
    error_message = "The expected Memory requests does not match."
  }
}

# Test Resource Definitions with multiple services
run "resource_definitions_multiple_services_complete_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service = "service1",
        resources = {
          limits   = { cpu = "200m", memory = "256Mi" },
          requests = { cpu = "100m", memory = "128Mi" }
        },
        replicas = 1
      },
      {
        service = "service2",
        resources = {
          limits   = { cpu = "300m", memory = "512Mi" },
          requests = { cpu = "200m", memory = "256Mi" }
        },
        replicas = 2
      }
    ]
  }

  assert {
    condition     = length(output.service_resource_definitions) == 2
    error_message = "The output does not contain both services."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].replicas == 1
    error_message = "The output does not contain the correct number of replicas for service1."
  }

  assert {
    condition     = output.service_resource_definitions["service2"].replicas == 2
    error_message = "The output does not contain the correct number of replicas for service2."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block) != null
    error_message = "The output does not contain the correct resource block."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits.cpu == "200m"
    error_message = "The expected CPU limits does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests.cpu == "100m"
    error_message = "The expected CPU requests does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service2"].resource_block).resources.limits.cpu == "300m"
    error_message = "The expected CPU limits does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service2"].resource_block).resources.requests.cpu == "200m"
    error_message = "The expected CPU requests does not match."
  }
}

# Test Resource Definitions with a single service and no limits or requests
run "resource_definitions_single_service_no_limits_requests_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service  = "service1",
        replicas = 1
      }
    ]
  }

  assert {
    condition     = length(output.service_resource_definitions) == 1
    error_message = "The output does not contain service1."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].replicas == 1
    error_message = "The output does not contain the correct number of replicas."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].resource_block == null
    error_message = "The output resource block should be null."
  }
}

# Test Resource Definitions with a single service having only limits defined
run "resource_definitions_single_service_only_limits_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service = "service1",
        resources = {
          limits = { cpu = "200m", memory = "256Mi" }
        },
        replicas = 1
      }
    ]
  }

  assert {
    condition     = length(output.service_resource_definitions) == 1
    error_message = "The output does not contain service1."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].replicas == 1
    error_message = "The output does not contain the correct number of replicas."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block) != null
    error_message = "The output does not contain the correct resource block."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits.cpu == "200m"
    error_message = "The expected CPU limits does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits.memory == "256Mi"
    error_message = "The expected CPU limits does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests == null
    error_message = "The expected CPU requests should not exist."
  }
}

# Test Resource Definitions with a single service having only requests defined
run "resource_definitions_single_service_only_requests_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service = "service1",
        resources = {
          requests = { cpu = "100m", memory = "128Mi" }
        },
        replicas = 1
      }
    ]
  }

  assert {
    condition     = length(output.service_resource_definitions) == 1
    error_message = "The output does not contain service1."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].replicas == 1
    error_message = "The output does not contain the correct number of replicas."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block) != null
    error_message = "The output does not contain the correct resource block."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests.cpu == "100m"
    error_message = "The expected CPU limits does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests.memory == "128Mi"
    error_message = "The expected CPU limits does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits == null
    error_message = "The expected CPU limits should not exist."
  }
}

# Test Resource Definitions with a single service having only requests Memory defined
run "resource_definitions_single_service_only_memory_requests_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service = "service1",
        resources = {
          requests = { memory = "128Mi" }
        },
        replicas = 1
      }
    ]
  }

  assert {
    condition     = length(output.service_resource_definitions) == 1
    error_message = "The output does not contain service1."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].replicas == 1
    error_message = "The output does not contain the correct number of replicas."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block) != null
    error_message = "The output does not contain the correct resource block."
  }

  assert {
    condition     = contains(keys(yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests), "cpu") == false
    error_message = "The CPU request should not appear at all."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests.memory == "128Mi"
    error_message = "The expected CPU request does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits == null
    error_message = "The resource limits should not exist."
  }
}

# Test Resource Definitions with a single service having only requests CPU defined
run "resource_definitions_single_service_only_cpu_requests_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service = "service1",
        resources = {
          requests = { cpu = "200m" }
        },
        replicas = 1
      }
    ]
  }

  assert {
    condition     = length(output.service_resource_definitions) == 1
    error_message = "The output does not contain service1."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].replicas == 1
    error_message = "The output does not contain the correct number of replicas."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block) != null
    error_message = "The output does not contain the correct resource block."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests.cpu == "200m"
    error_message = "The expected CPU request does not match."
  }

  assert {
    condition     = contains(keys(yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests), "memory") == false
    error_message = "The Memory request should not appear at all."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits == null
    error_message = "The resource limits should not exist."
  }
}

# Test Resource Definitions with a single service having only limits Memory defined
run "resource_definitions_single_service_only_memory_limits_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service = "service1",
        resources = {
          limits = { memory = "128Mi" }
        },
        replicas = 1
      }
    ]
  }

  assert {
    condition     = length(output.service_resource_definitions) == 1
    error_message = "The output does not contain service1."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].replicas == 1
    error_message = "The output does not contain the correct number of replicas."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block) != null
    error_message = "The output does not contain the correct resource block."
  }

  assert {
    condition     = contains(keys(yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits), "cpu") == false
    error_message = "The CPU limits should not exist."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits.memory == "128Mi"
    error_message = "The expected RAM limits does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests == null
    error_message = "The resources requests should not exist."
  }
}

# Test Resource Definitions with a single service having only limits CPU defined
run "resource_definitions_single_service_only_cpu_limits_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service = "service1",
        resources = {
          limits = { cpu = "200m" }
        },
        replicas = 1
      }
    ]
  }

  assert {
    condition     = length(output.service_resource_definitions) == 1
    error_message = "The output does not contain service1."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].replicas == 1
    error_message = "The output does not contain the correct number of replicas."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block) != null
    error_message = "The output does not contain the correct resource block."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits.cpu == "200m"
    error_message = "The expected CPU limits does not match."
  }

  assert {
    condition     = contains(keys(yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits), "memory") == false
    error_message = "The memory limits should not exist."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests == null
    error_message = "The resource requests should not exist."
  }
}

run "resource_definitions_multiple_services_partial_definitions_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service = "service1",
        resources = {
          limits   = { cpu = "", memory = "256Mi" },
          requests = { cpu = "100m", memory = "128Mi" }
        },
        replicas = 1
      },
      {
        service = "service2",
        resources = {
          limits   = { cpu = "300m", memory = "512Mi" },
          requests = { cpu = "200m", memory = "256Mi" }
        },
        replicas = 2
      }
    ]
  }

  assert {
    condition     = length(output.service_resource_definitions) == 2
    error_message = "The output does not contain both services."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].replicas == 1
    error_message = "The output does not contain the correct number of replicas for service1."
  }

  assert {
    condition     = output.service_resource_definitions["service2"].replicas == 2
    error_message = "The output does not contain the correct number of replicas for service2."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block) != null
    error_message = "The output does not contain the correct resource block."
  }

  assert {
    condition     = contains(keys(yamldecode(output.service_resource_definitions["service1"].resource_block).resources.limits), "cpu") == false
    error_message = "There should not be a CPU Limit defined for service 1."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service1"].resource_block).resources.requests.cpu == "100m"
    error_message = "The expected CPU requests does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service2"].resource_block).resources.limits.cpu == "300m"
    error_message = "The expected CPU limits does not match."
  }

  assert {
    condition     = yamldecode(output.service_resource_definitions["service2"].resource_block).resources.requests.cpu == "200m"
    error_message = "The expected CPU requests does not match."
  }
}


# Test istio proxy default resource values
run "istio_resources_default_values_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service  = "service1",
        replicas = 1
      }
    ]
  }

  assert {
    condition     = output.service_resource_definitions["service1"].istio_proxy_resources != null
    error_message = "The output does not contain the correct resource block."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].istio_proxy_resources.requests.cpu == "10m"
    error_message = "The expected CPU requests does not match."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].istio_proxy_resources.limits.memory == "128Mi"
    error_message = "The expected Memory limits does not match."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].istio_proxy_resources.requests.memory == "64Mi"
    error_message = "The expected Memory requests does not match."
  }
}

# Test overriding istio proxy default resource values
run "istio_resources_override_values_test" {
  command = plan

  variables {
    resource_definitions = [
      {
        service = "service1",
        istio_proxy_resources = {
          limits   = { cpu = "500m", memory = "500Mi" }
          requests = { cpu = "100m", memory = "100Mi" }
        }
        replicas = 1
      }
    ]
  }

  assert {
    condition     = output.service_resource_definitions["service1"].istio_proxy_resources != null
    error_message = "The output does not contain the correct resource block."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].istio_proxy_resources.limits.cpu == "500m"
    error_message = "The expected CPU limits does not match."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].istio_proxy_resources.requests.cpu == "100m"
    error_message = "The expected CPU requests does not match."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].istio_proxy_resources.limits.memory == "500Mi"
    error_message = "The expected Memory limits does not match."
  }

  assert {
    condition     = output.service_resource_definitions["service1"].istio_proxy_resources.requests.memory == "100Mi"
    error_message = "The expected Memory requests does not match."
  }
}
