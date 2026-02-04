
run "timeout_retry_empty_overrides_test" {
  command = plan
  variables {
    timeout_retry_defaults = [{ service = "service1" }]
  }
  assert {
    condition     = jsonencode(output.service_timeout_retry_definitions) == jsonencode({ "service1" : "{}" })
    error_message = "The output ${jsonencode(output.service_timeout_retry_definitions)} does not match the expected empty configuration: ${jsonencode({})}"
  }
}
run "timeout_retry_empty_defaults_test" {
  command = plan
  variables {
    timeout_retry_overrides = [{ service = "service1" }]
  }
  assert {
    condition     = jsonencode(output.service_timeout_retry_definitions) == jsonencode({ "service1" : "{}" })
    error_message = "The output ${jsonencode(output.service_timeout_retry_definitions)} does not match the expected empty configuration: ${jsonencode({})}"
  }
}

run "timeout_retry_merge_config_test" {
  command = plan
  variables {
    timeout_retry_defaults  = [{ service = "service1", retries = { attempts = 2 } }]
    timeout_retry_overrides = [{ service = "service1", timeout = "1s" }]
  }
  assert {
    condition = jsonencode(output.service_timeout_retry_definitions) == jsonencode({
      "service1" : trimspace(yamlencode({ retries = { attempts = 2 }, timeout = "1s" }))
    })
    error_message = "The output ${jsonencode(output.service_timeout_retry_definitions)} does not match the expected full configuration."
  }
}

run "timeout_retry_override_test" {
  command = plan
  variables {
    timeout_retry_defaults  = [{ service = "service1", retries = { attempts = 1, perTryTimeout = "1s", retryOn = "1xx" }, timeout = "1s" }]
    timeout_retry_overrides = [{ service = "service1", retries = { attempts = 2, perTryTimeout = "2s", retryOn = "2xx" }, timeout = "2s" }]
  }
  assert {
    condition = jsonencode(output.service_timeout_retry_definitions) == jsonencode({
      "service1" : trimspace(yamlencode({ retries = { attempts = 2, perTryTimeout = "2s", retryOn = "2xx" }, timeout = "2s" }))
    })
    error_message = "The output ${jsonencode(output.service_timeout_retry_definitions)} does not match the expected full configuration."
  }
}

run "timeout_retry_full_config_test" {
  command = plan
  variables {
    timeout_retry_defaults = [
      { service = "service1", timeout = "1s", retries = { attempts = 1, perTryTimeout = "1s", retryOn = "1xx" } },
      { service = "service2", timeout = "2s", retries = { attempts = 2, perTryTimeout = "2s", retryOn = "2xx" } }
    ]
    timeout_retry_overrides = [
      { service = "service2", timeout = "9s", retries = { attempts = 9, perTryTimeout = "9s", retryOn = "9xx" } },
      { service = "service3", timeout = "3s", retries = { attempts = 3, perTryTimeout = "3s", retryOn = "3xx" } }
    ]
  }
  assert {
    condition = jsonencode(output.service_timeout_retry_definitions) == jsonencode({
      service1 : trimspace(yamlencode({ timeout = "1s", retries = { attempts = 1, perTryTimeout = "1s", retryOn = "1xx" } })),
      service2 : trimspace(yamlencode({ timeout = "9s", retries = { attempts = 9, perTryTimeout = "9s", retryOn = "9xx" } })),
      service3 : trimspace(yamlencode({ timeout = "3s", retries = { attempts = 3, perTryTimeout = "3s", retryOn = "3xx" } }))
    })
    error_message = "The output ${jsonencode(output.service_timeout_retry_definitions)} does not match the expected full configuration."
  }
}
