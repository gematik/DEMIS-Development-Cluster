run "timeout_retry_empty_overrides_test" {
  command = plan
  variables {
    custom_timeout_retry = [{ service = "service1" }]
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
    custom_timeout_retry    = [{ service = "service1", retries = { attempts = 2 } }]
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
    custom_timeout_retry    = [{ service = "service1", retries = { attempts = 1, perTryTimeout = "1s", retryOn = "1xx" }, timeout = "1s" }]
    timeout_retry_overrides = [{ service = "service1", retries = { attempts = 2, perTryTimeout = "2s", retryOn = "2xx" }, timeout = "4s" }]
  }
  assert {
    condition = jsonencode(output.service_timeout_retry_definitions) == jsonencode({
      "service1" : trimspace(yamlencode({ retries = { attempts = 2, perTryTimeout = "2s", retryOn = "2xx" }, timeout = "4s" }))
    })
    error_message = "The output ${jsonencode(output.service_timeout_retry_definitions)} does not match the expected full configuration."
  }
}

run "timeout_retry_full_config_test" {
  command = plan
  variables {
    custom_timeout_retry = [
      { service = "service1", timeout = "1s", retries = { attempts = 1, perTryTimeout = "1s", retryOn = "1xx" } },
      { service = "service2", timeout = "4s", retries = { attempts = 2, perTryTimeout = "2s", retryOn = "2xx" } }
    ]
    timeout_retry_overrides = [
      { service = "service2", timeout = "9s", retries = { attempts = 3, perTryTimeout = "3s", retryOn = "9xx" } },
      { service = "service3", timeout = "6s", retries = { attempts = 3, perTryTimeout = "2s", retryOn = "3xx" } }
    ]
  }
  assert {
    condition = jsonencode(output.service_timeout_retry_definitions) == jsonencode({
      service1 : trimspace(yamlencode({ timeout = "1s", retries = { attempts = 1, perTryTimeout = "1s", retryOn = "1xx" } })),
      service2 : trimspace(yamlencode({ timeout = "9s", retries = { attempts = 3, perTryTimeout = "3s", retryOn = "9xx" } })),
      service3 : trimspace(yamlencode({ timeout = "6s", retries = { attempts = 3, perTryTimeout = "2s", retryOn = "3xx" } }))
    })
    error_message = "The output ${jsonencode(output.service_timeout_retry_definitions)} does not match the expected full configuration."
  }
}

# Services in the `service_names` list receive the built-in common default (5s / 1 attempt / 5s)
run "builtin_common_default_test" {
  command = plan
  variables {
    service_names = ["service1"]
  }
  assert {
    condition = jsonencode(output.service_timeout_retry_definitions) == jsonencode({
      service1 : trimspace(yamlencode({ timeout = "5s", retries = { attempts = 1, perTryTimeout = "5s" } }))
    })
    error_message = "The output ${jsonencode(output.service_timeout_retry_definitions)} does not match the expected built-in common default."
  }
}

# Services in the `no_retries_services` list receive the built-in no-retries default (0 attempts)
run "builtin_no_retries_default_test" {
  command = plan
  variables {
    no_retries_services = ["service1"]
  }
  assert {
    condition = jsonencode(output.service_timeout_retry_definitions) == jsonencode({
      service1 : trimspace(yamlencode({ retries = { attempts = 0 } }))
    })
    error_message = "The output ${jsonencode(output.service_timeout_retry_definitions)} does not match the expected built-in no-retries default."
  }
}

# no_retries_services takes precedence over the common default for the same name
run "builtin_no_retries_precedence_test" {
  command = plan
  variables {
    service_names       = ["service1"]
    no_retries_services = ["service1"]
  }
  assert {
    condition = jsonencode(output.service_timeout_retry_definitions) == jsonencode({
      service1 : trimspace(yamlencode({ retries = { attempts = 0 } }))
    })
    error_message = "no_retries_services should take precedence over the common default."
  }
}

# Explicit overrides take precedence over the built-in common default
run "builtin_default_overridden_test" {
  command = plan
  variables {
    service_names           = ["service1"]
    timeout_retry_overrides = [{ service = "service1", timeout = "10s" }]
  }
  assert {
    condition = jsonencode(output.service_timeout_retry_definitions) == jsonencode({
      service1 : trimspace(yamlencode({ timeout = "10s", retries = { attempts = 1, perTryTimeout = "5s" } }))
    })
    error_message = "Overrides should take precedence over the built-in common default."
  }
}

# Validation fails when timeout < perTryTimeout * attempts
run "timeout_validation_failure_test" {
  command = plan
  variables {
    custom_timeout_retry = [{ service = "service1", timeout = "1s", retries = { attempts = 3, perTryTimeout = "1s" } }]
  }
  expect_failures = [
    output.service_timeout_retry_definitions,
  ]
}

# Validation fails with mixed duration units (999ms < 1s * 1)
run "timeout_validation_failure_units_test" {
  command = plan
  variables {
    custom_timeout_retry = [{ service = "service1", timeout = "999ms", retries = { attempts = 1, perTryTimeout = "1s" } }]
  }
  expect_failures = [
    output.service_timeout_retry_definitions,
  ]
}

# Explicit defaults are not polluted with the common default; validation is skipped
# when no timeout is set (e.g. object storage), even if the service is in service_names.
run "timeout_validation_skipped_without_timeout_test" {
  command = plan
  variables {
    service_names        = ["service1"]
    custom_timeout_retry = [{ service = "service1", retries = { attempts = 3, perTryTimeout = "300s" } }]
  }
  assert {
    condition = jsonencode(output.service_timeout_retry_definitions) == jsonencode({
      service1 : trimspace(yamlencode({ retries = { attempts = 3, perTryTimeout = "300s" } }))
    })
    error_message = "Validation should be skipped when no timeout is set."
  }
}

# Duration parsing works across units (2m >= 30s * 3)
run "timeout_validation_units_pass_test" {
  command = plan
  variables {
    custom_timeout_retry = [{ service = "service1", timeout = "2m", retries = { attempts = 3, perTryTimeout = "30s" } }]
  }
  assert {
    condition = jsonencode(output.service_timeout_retry_definitions) == jsonencode({
      service1 : trimspace(yamlencode({ timeout = "2m", retries = { attempts = 3, perTryTimeout = "30s" } }))
    })
    error_message = "Duration parsing across units failed for a valid configuration."
  }
}
