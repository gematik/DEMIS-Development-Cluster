# Test Feature Flags
run "feature_flags_correct_test" {
  command = plan

  variables {
    all_services = ["service1", "service2"]
    feature_flags = [
      {
        services   = ["service1", "service2"],
        flag_name  = "FEATURE_FLAG_TEST",
        flag_value = true
      },
      {
        services   = ["all"],
        flag_name  = "FEATURE_FLAG_TEST_ALL",
        flag_value = true
      }
    ]
  }

  assert {
    condition     = contains(keys(output.service_feature_flags), "service1") && contains(keys(output.service_feature_flags), "service2")
    error_message = "The Feature Flags are not grouped by service."
  }

  assert {
    condition     = output.service_feature_flags["service1"] == { "FEATURE_FLAG_TEST" = true, "FEATURE_FLAG_TEST_ALL" = true } && output.service_feature_flags["service2"] == { "FEATURE_FLAG_TEST" = true, "FEATURE_FLAG_TEST_ALL" = true }
    error_message = "The Feature Flag 'FEATURE_FLAG_TEST' is not set to true for the services."
  }
}

# Test Feature Flags with wrong value
run "feature_flags_wrong_test" {
  command = plan

  variables {
    all_services = ["service1", "service2"]
    feature_flags = [
      {
        services   = ["service1", "service2"],
        flag_name  = "feature_my_feature",
        flag_value = true
      }
    ]
  }

  expect_failures = [var.feature_flags]
}

# Test Configuration Options
run "config_options_correct_test" {
  command = plan

  variables {
    all_services = ["service1", "service2"]
    config_options = [
      {
        services     = ["service1", "service2"],
        option_name  = "CONFIG_TEST",
        option_value = "my_value"
      },
      {
        services     = ["service2"],
        option_name  = "CONFIG_TEST_2",
        option_value = "my_value_2"
      },
      {
        services     = ["all"],
        option_name  = "CONFIG_TEST_ALL",
        option_value = "all"
      }
    ]
  }

  assert {
    condition     = contains(keys(output.service_config_options), "service1") && contains(keys(output.service_config_options), "service2")
    error_message = "The Feature Flags are not grouped by service."
  }

  assert {
    condition     = output.service_config_options["service1"] == { "CONFIG_TEST" = "my_value", "CONFIG_TEST_ALL" = "all" } && output.service_config_options["service2"] == { "CONFIG_TEST" = "my_value", "CONFIG_TEST_2" = "my_value_2", "CONFIG_TEST_ALL" = "all" }
    error_message = "The Operational Flags 'CONFIG_TEST' and 'CONFIG_TEST_2' were not correctly set."
  }
}

# ignore null Configuration Options
run "config_options_correct_test" {
  command = plan

  variables {
    all_services = ["service1"]
    config_options = [
      {
        services     = ["service1"],
        option_name  = "CONFIG_TEST",
        option_value = null
      }
    ]
  }

  assert {
    condition     = contains(keys(output.service_config_options), "service1")
    error_message = "The Feature Flags are not grouped by service."
  }

  assert {
    condition     = output.service_config_options["service1"] == {}
    error_message = "Config option with null value should be ignored."
  }
}

# Test Configuration options with wrong value
run "config_options_wrong_test" {
  command = plan

  variables {
    all_services = ["service1", "service2"]
    config_options = [
      {
        services     = ["service1", "service2"],
        option_name  = "CONFIG_TEST",
        option_value = "my_value"
      },
      {
        services     = ["service1", "service2"],
        option_name  = "",
        option_value = ""
      }
    ]
  }

  expect_failures = [var.config_options]
}

# all services from feature flags must be in all_services list
run "all_services_ff_validation_test" {
  command = plan

  variables {
    all_services = ["service1"]
    feature_flags = [
      {
        services   = ["service1", "service2"],
        flag_name  = "FEATURE_FLAG_TEST",
        flag_value = true
      }
    ]
  }

  expect_failures = [var.all_services]
}

# all services from config options must be in all_services list
run "all_services_config_validation_test" {
  command = plan

  variables {
    all_services = ["service1"]
    config_options = [
      {
        services     = ["service1", "service2"],
        option_name  = "CONFIG_TEST",
        option_value = "my_value"
      }
    ]
  }

  expect_failures = [var.all_services]
}

