run "valid_minimal_template_test" {
  command = apply

  variables {
    input_mapping_path = "testdata/positive/valid-minimal.yaml"
  }

  assert {
    condition     = jsonencode(output.rules) == jsonencode({ svc-minimal = [{}] })
    error_message = "Expected a single empty rule object for svc-minimal, got ${jsonencode(output.rules)}"
  }
}

run "valid_service_defaults_test" {
  command = apply

  variables {
    input_mapping_path = "testdata/positive/valid-service-defaults.yaml"
  }

  assert {
    condition     = length(output.rules["svc-defaults"]) == 1
    error_message = "Expected exactly one rule for svc-defaults, got ${length(output.rules["svc-defaults"])}"
  }

  assert {
    condition     = output.rules["svc-defaults"][0].match[0].uri.prefix == "/v1/patients"
    error_message = "Service-level uri_template was not rendered as expected."
  }

  assert {
    condition     = output.rules["svc-defaults"][0].match[0].ignoreUriCase == true
    error_message = "ignoreUriCase should be preserved on the generated match block."
  }

  assert {
    condition     = output.rules["svc-defaults"][0].match[0].headers["x-env"].exact == "prod"
    error_message = "Expected header exact match from service defaults."
  }

  assert {
    condition     = jsonencode(output.rules["svc-defaults"][0].match[0].withoutHeaders) == jsonencode({ "x-internal" = {} })
    error_message = "Expected withoutHeaders to be expanded from the array syntax."
  }

  assert {
    condition     = output.rules["svc-defaults"][0].rewrite.uri == "/v1/target"
    error_message = "Expected simple rewrite target from service defaults."
  }

  assert {
    condition     = output.rules["svc-defaults"][0].delegate.name == "delegate-v1" && output.rules["svc-defaults"][0].delegate.namespace == "istio-v1"
    error_message = "Expected delegate variables to be substituted from service defaults."
  }

  assert {
    condition     = output.rules["svc-defaults"][0].headers.request.set["x-service-version"] == "v1" && output.rules["svc-defaults"][0].headers.request.set["x-static"] == "fixed"
    error_message = "Expected service-level additional headers to be rendered into request header setters."
  }
}

run "valid_route_overrides_test" {
  command = apply

  variables {
    input_mapping_path = "testdata/positive/valid-route-overrides.yaml"
  }

  assert {
    condition     = length(output.rules["svc-overrides"]) == 1
    error_message = "Expected exactly one rule for svc-overrides."
  }

  assert {
    condition     = output.rules["svc-overrides"][0].match[0].uri.regex == "/api/v2/items"
    error_message = "Expected route-level regex match rendering with merged variables."
  }

  assert {
    condition     = output.rules["svc-overrides"][0].match[0].headers["x-version"].exact == "v2"
    error_message = "Expected route-level header match substitution."
  }

  assert {
    condition     = jsonencode(output.rules["svc-overrides"][0].match[0].withoutHeaders) == jsonencode({ "x-remove" = {} })
    error_message = "Expected object-form without_headers to pass through unchanged."
  }

  assert {
    condition     = output.rules["svc-overrides"][0].rewrite.uriRegexRewrite.match == "/api/(.*)" && output.rules["svc-overrides"][0].rewrite.uriRegexRewrite.rewrite == "/rewritten/$1/v2"
    error_message = "Expected regex rewrite to be rendered from the route-level override."
  }

  assert {
    condition     = output.rules["svc-overrides"][0].delegate.name == "delegate-v2" && output.rules["svc-overrides"][0].delegate.namespace == "us-ns"
    error_message = "Expected route-level delegate to override the service-level delegate."
  }

  assert {
    condition     = output.rules["svc-overrides"][0].headers.request.set["x-route"] == "v2" && output.rules["svc-overrides"][0].headers.request.set["x-shared"] == "us"
    error_message = "Expected route and service additional headers to merge after variable substitution."
  }
}

run "valid_global_template_variables_test" {
  command = apply

  variables {
    input_mapping_path = "testdata/positive/valid-global-template-variables.yaml"
    global_template_variables = {
      tenant = "global"
    }
  }

  assert {
    condition     = output.rules["svc-global"][0].match[0].uri.prefix == "/global/records"
    error_message = "Expected global template variables to override service-level template variables."
  }

  assert {
    condition     = output.rules["svc-global"][0].headers.request.set["x-tenant"] == "global"
    error_message = "Expected global template variables to be applied to additional headers."
  }
}

run "valid_match_method_shapes_test" {
  command = apply

  variables {
    input_mapping_path = "testdata/positive/valid-match-methods.yaml"
  }

  assert {
    condition     = length(output.rules["svc-methods"]) == 1
    error_message = "Expected one route block for svc-methods."
  }

  assert {
    condition     = length(output.rules["svc-methods"][0].match) == 3
    error_message = "Expected all three schema-valid method shapes to survive planning."
  }
}

run "valid_http_method_output_test" {
  command = apply

  variables {
    input_mapping_path = "testdata/positive/valid-http-method-output.yaml"
  }

  assert {
    condition     = length(output.rules["svc-http-methods"]) == 1
    error_message = "Expected exactly one rule block for svc-http-methods, got ${length(output.rules["svc-http-methods"])}."
  }

  assert {
    condition     = length(output.rules["svc-http-methods"][0].match) == 7
    error_message = "Expected 7 match entries (5 exact + 1 prefix + 1 regex), got ${length(output.rules["svc-http-methods"][0].match)}."
  }

  # Verify all five valid exact HTTP method enum values are passed through correctly
  assert {
    condition     = output.rules["svc-http-methods"][0].match[0].method.exact == "GET"
    error_message = "Expected exact method GET at match[0], got ${jsonencode(output.rules["svc-http-methods"][0].match[0].method)}."
  }

  assert {
    condition     = output.rules["svc-http-methods"][0].match[1].method.exact == "POST"
    error_message = "Expected exact method POST at match[1], got ${jsonencode(output.rules["svc-http-methods"][0].match[1].method)}."
  }

  assert {
    condition     = output.rules["svc-http-methods"][0].match[2].method.exact == "PUT"
    error_message = "Expected exact method PUT at match[2], got ${jsonencode(output.rules["svc-http-methods"][0].match[2].method)}."
  }

  assert {
    condition     = output.rules["svc-http-methods"][0].match[3].method.exact == "DELETE"
    error_message = "Expected exact method DELETE at match[3], got ${jsonencode(output.rules["svc-http-methods"][0].match[3].method)}."
  }

  assert {
    condition     = output.rules["svc-http-methods"][0].match[4].method.exact == "PATCH"
    error_message = "Expected exact method PATCH at match[4], got ${jsonencode(output.rules["svc-http-methods"][0].match[4].method)}."
  }

  # Verify prefix and regex method shapes are passed through correctly
  assert {
    condition     = output.rules["svc-http-methods"][0].match[5].method.prefix == "GE"
    error_message = "Expected prefix method 'GE' at match[5], got ${jsonencode(output.rules["svc-http-methods"][0].match[5].method)}."
  }

  assert {
    condition     = output.rules["svc-http-methods"][0].match[6].method.regex == "^(GET|POST)$"
    error_message = "Expected regex method '^(GET|POST)$' at match[6], got ${jsonencode(output.rules["svc-http-methods"][0].match[6].method)}."
  }

  # Verify URIs are rendered alongside their method constraints
  assert {
    condition     = output.rules["svc-http-methods"][0].match[0].uri.prefix == "/get-endpoint"
    error_message = "Expected URI prefix '/get-endpoint' co-rendered with GET method at match[0]."
  }

  assert {
    condition     = output.rules["svc-http-methods"][0].match[6].uri.prefix == "/regex-endpoint"
    error_message = "Expected URI prefix '/regex-endpoint' co-rendered with regex method at match[6]."
  }
}

run "valid_disabled_and_filtering_test" {
  command = apply

  variables {
    input_mapping_path = "testdata/positive/valid-disabled-and-filtering.yaml"
    service_list       = ["svc-enabled", "svc-missing"]
  }

  assert {
    condition     = contains(keys(output.rules), "svc-enabled") && contains(keys(output.rules), "svc-missing")
    error_message = "Expected requested services to be present in the output map."
  }

  assert {
    condition     = !contains(keys(output.rules), "svc-disabled")
    error_message = "Disabled services should not produce output rules."
  }

  assert {
    condition     = length(output.rules["svc-enabled"]) == 1 && output.rules["svc-enabled"][0].match[0].uri.prefix == "/enabled"
    error_message = "Expected enabled service rules to render normally."
  }

  assert {
    condition     = jsonencode(output.rules["svc-missing"]) == jsonencode([])
    error_message = "Services requested via service_list but absent from the input should resolve to an empty rule list."
  }
}

run "invalid_root_missing_traffic_routes_templates_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-root-missing-traffic-routes-templates.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_root_additional_property_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-root-additional-property.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_missing_service_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-missing-service.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_missing_http_route_configs_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-missing-http-route-configs.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_missing_enabled_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-missing-enabled.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_additional_property_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-additional-property.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_empty_service_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-empty-service.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_enabled_not_boolean_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-enabled-not-boolean.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_variables_non_string_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-variables-non-string.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_delegate_missing_namespace_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-delegate-missing-namespace.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_delegate_additional_property_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-delegate-additional-property.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_additional_headers_empty_value_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-additional-headers-empty-value.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_match_empty_uri_template_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-matches-empty.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_rewrite_missing_target_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-rewrite-missing-target.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_http_route_configs_empty_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-http-route-configs-empty.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_http_route_config_empty_object_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-http-route-config-empty-object.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_http_route_config_additional_property_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-http-route-config-additional-property.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_http_route_config_variables_non_string_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-http-route-config-variables-non-string.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_http_route_config_matches_empty_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-http-route-config-matches-empty.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_http_route_config_match_missing_uri_template_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-http-route-config-match-missing-uri-template.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_http_route_config_regex_rewrite_missing_match_template_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-http-route-config-rewrite-regex-missing-match-template.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_match_additional_property_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-match-additional-property.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_match_header_empty_value_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-match-header-empty-value.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_match_without_headers_empty_string_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-match-without-headers-empty-string.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_match_method_exact_enum_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-match-method-exact-enum.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_match_type_enum_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-match-type-enum.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_match_ignore_uri_case_not_boolean_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-match-ignore-uri-case-not-boolean.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_root_service_property_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-root-service-property.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_template_uri_template_property_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-template-uri-template-property.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_http_route_config_service_property_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-http-route-config-service-property.yaml"
  }

  expect_failures = [data.external.schema_validation]
}

run "invalid_match_rewrite_property_test" {
  command = plan

  variables {
    input_mapping_path = "testdata/negative/invalid-match-rewrite-property.yaml"
  }

  expect_failures = [data.external.schema_validation]
}
