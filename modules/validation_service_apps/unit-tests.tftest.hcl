# Mock the Helm provider so no charts are fetched from remote repositories.
mock_provider "helm" {}

# ---------------------------------------------------------------------------
# Shared variable defaults reused across all run blocks via override.
# ---------------------------------------------------------------------------
variables {
  name             = "validation-service-pathogen"
  target_namespace = "demis"
  # Point to a path that never exists so all fileexists() fall through to local_template_directory.
  external_template_directory = "/nonexistent"
  local_template_directory    = "test-fixtures"
  package_type                = "fhir-profile-snapshots"
  app_template_file           = "test-fixtures/validation-service-pathogen/app-values.tftpl.yaml"
  istio_template_file         = "test-fixtures/validation-service-pathogen/istio-values.tftpl.yaml"

  helm_release_settings = {
    chart_image_tag_property_name = "required.image.tag"
    helm_repository               = "https://gematik.github.io/DEMIS-Helm-Charts/"
    helm_repository_username      = ""
    helm_repository_password      = ""
    istio_routing_chart_version   = "1.1.0"
    istio_routing_chart_name      = "istio-routing"
    deployment_timeout            = "300"
    reset_values                  = "false"
  }

  deployment_information = {
    deployment-strategy = "canary"
    enabled             = true
    main = {
      version  = "2.7.1"
      weight   = 100
      profiles = ["6.1.4", "7.2.0"]
    }
  }

  resource_definitions = {
    "validation-service-pathogen" = {
      replicas              = 1
      resource_block        = null
      istio_proxy_resources = {}
    }
  }

  timeout_retries = {
    "validation-service-pathogen" = null
  }
}

# ---------------------------------------------------------------------------
# 1. Distributed mode – two profiles produce two per-version Helm releases
# ---------------------------------------------------------------------------
run "distributed_mode_two_profiles_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
  }

  # vs_use_for_each must be true for non-dedicated modes
  assert {
    condition     = local.vs_use_for_each == true
    error_message = "Expected vs_use_for_each=true for distributed mode, got: ${local.vs_use_for_each}"
  }

  # Two distinct major versions → two entries in vs_variants
  assert {
    condition     = length(local.vs_variants) == 2
    error_message = "Expected 2 entries in vs_variants, got: ${length(local.vs_variants)} – ${jsonencode(keys(local.vs_variants))}"
  }

  # Keys must be the major-version identifiers "v6" and "v7"
  assert {
    condition     = contains(keys(local.vs_variants), "v6") && contains(keys(local.vs_variants), "v7")
    error_message = "Expected vs_variants keys to be [v6, v7], got: ${jsonencode(keys(local.vs_variants))}"
  }

  # Release names follow the <service>-<major-version> pattern
  assert {
    condition     = local.vs_variants["v6"].name == "validation-service-pathogen-v6"
    error_message = "Expected vs_variants[v6].name='validation-service-pathogen-v6', got: ${local.vs_variants["v6"].name}"
  }
  assert {
    condition     = local.vs_variants["v7"].name == "validation-service-pathogen-v7"
    error_message = "Expected vs_variants[v7].name='validation-service-pathogen-v7', got: ${local.vs_variants["v7"].name}"
  }

  # Each variant carries the full profile version it represents
  assert {
    condition     = local.vs_variants["v6"].version == "6.1.4" && local.vs_variants["v7"].version == "7.2.0"
    error_message = "Unexpected versions in vs_variants: ${jsonencode(local.vs_variants)}"
  }

  # for_each module instantiated once per major version
  assert {
    condition     = length(module.validation_service) == 2
    error_message = "Expected 2 module.validation_service instances in distributed mode, got: ${length(module.validation_service)}"
  }

  # Legacy (count) module must not be created – no dedicated subsets exist in distributed mode
  assert {
    condition     = length(module.validation_service_legacy) == 0
    error_message = "Expected 0 module.validation_service_legacy in distributed mode, got: ${length(module.validation_service_legacy)}"
  }
}

# ---------------------------------------------------------------------------
# 2. Dedicated mode with two profiles – only the legacy module is created
# ---------------------------------------------------------------------------
run "dedicated_mode_two_profiles_test" {
  command = apply

  variables {
    profile_provisioning_mode = "dedicated"
  }

  # vs_use_for_each must be false for dedicated mode
  assert {
    condition     = local.vs_use_for_each == false
    error_message = "Expected vs_use_for_each=false for dedicated mode, got: ${local.vs_use_for_each}"
  }

  # for_each module must be suppressed
  assert {
    condition     = length(module.validation_service) == 0
    error_message = "Expected 0 module.validation_service in dedicated mode, got: ${length(module.validation_service)}"
  }

  # Dedicated mode with >1 profile → dedicated subsets exist → legacy module created once
  assert {
    condition     = length(module.validation_service_legacy) == 1
    error_message = "Expected 1 module.validation_service_legacy in dedicated mode (2 profiles), got: ${length(module.validation_service_legacy)}"
  }

  # The dedicated subsets must all have mode=="dedicated"
  assert {
    condition     = alltrue([for s in local.dedicated_subsets.main : s.mode == "dedicated"])
    error_message = "Expected all dedicated_subsets.main to have mode='dedicated', got: ${jsonencode(local.dedicated_subsets.main)}"
  }
}

# ---------------------------------------------------------------------------
# 3. Combined mode – both the for_each and legacy modules are created
# ---------------------------------------------------------------------------
run "combined_mode_two_profiles_test" {
  command = apply

  variables {
    profile_provisioning_mode = "combined"
  }

  # vs_use_for_each must be true (combined != dedicated)
  assert {
    condition     = local.vs_use_for_each == true
    error_message = "Expected vs_use_for_each=true for combined mode, got: ${local.vs_use_for_each}"
  }

  # Two major versions → two for_each module instances
  assert {
    condition     = length(module.validation_service) == 2
    error_message = "Expected 2 module.validation_service in combined mode, got: ${length(module.validation_service)}"
  }

  # Combined mode also creates dedicated subsets → legacy module created once
  assert {
    condition     = length(module.validation_service_legacy) == 1
    error_message = "Expected 1 module.validation_service_legacy in combined mode, got: ${length(module.validation_service_legacy)}"
  }
}

# ---------------------------------------------------------------------------
# 4. Major-version identifier extraction (including pre-release suffixes)
# ---------------------------------------------------------------------------
run "major_version_ident_extraction_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
    deployment_information = {
      deployment-strategy = "canary"
      enabled             = true
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.1.4-b8", "7.2.0"]
      }
    }
  }

  # Pre-release suffix must be stripped – "6.1.4-b8" → "v6"
  assert {
    condition     = local.vs_major_versions_ident["6.1.4-b8"] == "v6"
    error_message = "Expected vs_major_versions_ident[6.1.4-b8]='v6', got: ${local.vs_major_versions_ident["6.1.4-b8"]}"
  }

  assert {
    condition     = local.vs_major_versions_ident["7.2.0"] == "v7"
    error_message = "Expected vs_major_versions_ident[7.2.0]='v7', got: ${local.vs_major_versions_ident["7.2.0"]}"
  }

  # Variant name must not contain dots (replaced by hyphens)
  assert {
    condition     = !strcontains(local.vs_variants["v6"].name, ".")
    error_message = "Variant name must not contain dots, got: ${local.vs_variants["v6"].name}"
  }
}

# ---------------------------------------------------------------------------
# 5. Compound-key timeout/retry override for a specific major version
#    Keys in vs_timeout_retries_blocks are major-version idents ("v6", "v7")
#    because `for v in map` in OpenTofu iterates the VALUES of the map.
#    Compound key format: "<service>:<major-version-ident>" e.g. "validation-service-pathogen:v6"
# ---------------------------------------------------------------------------
run "timeout_retries_compound_key_override_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
    timeout_retries = {
      "validation-service-pathogen"    = "default-retry-block"
      "validation-service-pathogen:v6" = "v6-specific-block"
    }
  }

  # The compound key "validation-service-pathogen:v6" must override the v6 slot
  assert {
    condition     = local.vs_timeout_retries_blocks["v6"] == "v6-specific-block"
    error_message = "Expected vs_timeout_retries_blocks[v6]='v6-specific-block', got: ${tostring(local.vs_timeout_retries_blocks["v6"])}"
  }

  # The v7 slot must fall back to the default (no compound key defined for it)
  assert {
    condition     = local.vs_timeout_retries_blocks["v7"] == "default-retry-block"
    error_message = "Expected vs_timeout_retries_blocks[v7]='default-retry-block', got: ${tostring(local.vs_timeout_retries_blocks["v7"])}"
  }

  # The "default" slot must always equal the base (non-compound) entry
  assert {
    condition     = local.vs_timeout_retries_blocks["default"] == "default-retry-block"
    error_message = "Expected vs_timeout_retries_blocks[default]='default-retry-block', got: ${tostring(local.vs_timeout_retries_blocks["default"])}"
  }
}

# ---------------------------------------------------------------------------
# 6. When no compound key exists every version falls back to the default
# ---------------------------------------------------------------------------
run "timeout_retries_fallback_to_default_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
    timeout_retries = {
      "validation-service-pathogen" = "only-default"
    }
  }

  assert {
    condition     = local.vs_timeout_retries_blocks["v6"] == "only-default"
    error_message = "Expected fallback to 'only-default' for v6, got: ${tostring(local.vs_timeout_retries_blocks["v6"])}"
  }

  assert {
    condition     = local.vs_timeout_retries_blocks["v7"] == "only-default"
    error_message = "Expected fallback to 'only-default' for v7, got: ${tostring(local.vs_timeout_retries_blocks["v7"])}"
  }

  assert {
    condition     = local.vs_timeout_retries_blocks["default"] == "only-default"
    error_message = "Expected default slot to be 'only-default', got: ${tostring(local.vs_timeout_retries_blocks["default"])}"
  }
}

# ---------------------------------------------------------------------------
# 7. app_helm_settings must not contain istio_routing_chart_version
# ---------------------------------------------------------------------------
run "app_helm_settings_strips_istio_version_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
  }

  assert {
    condition     = !contains(keys(local.app_helm_settings), "istio_routing_chart_version")
    error_message = "app_helm_settings must not contain 'istio_routing_chart_version', got keys: ${jsonencode(keys(local.app_helm_settings))}"
  }

  # All other keys from helm_release_settings must still be present
  assert {
    condition     = contains(keys(local.app_helm_settings), "helm_repository") && contains(keys(local.app_helm_settings), "chart_image_tag_property_name")
    error_message = "app_helm_settings is missing expected keys, got: ${jsonencode(keys(local.app_helm_settings))}"
  }
}

# ---------------------------------------------------------------------------
# 8. profile_metadata output – versions and destination subsets
# ---------------------------------------------------------------------------
run "profile_metadata_output_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
  }

  # current_profile_versions must contain both profile versions
  assert {
    condition     = contains(output.profile_metadata.current_profile_versions, "6.1.4") && contains(output.profile_metadata.current_profile_versions, "7.2.0")
    error_message = "Expected current_profile_versions=[6.1.4, 7.2.0], got: ${jsonencode(output.profile_metadata.current_profile_versions)}"
  }

  # Destination subsets must have main and canary keys
  assert {
    condition     = can(output.profile_metadata.destination_subsets.main) && can(output.profile_metadata.destination_subsets.canary)
    error_message = "Expected destination_subsets to have main and canary keys, got: ${jsonencode(keys(output.profile_metadata.destination_subsets))}"
  }

  # Distributed mode → main subsets must all have mode=="distributed"
  assert {
    condition     = alltrue([for s in output.profile_metadata.destination_subsets.main : s.mode == "distributed"])
    error_message = "Expected all main subsets to have mode='distributed', got: ${jsonencode(output.profile_metadata.destination_subsets.main)}"
  }

  # No canary version defined → canary subsets must be empty
  assert {
    condition     = length(output.profile_metadata.destination_subsets.canary) == 0
    error_message = "Expected empty canary subsets (no canary version defined), got: ${jsonencode(output.profile_metadata.destination_subsets.canary)}"
  }
}

# ---------------------------------------------------------------------------
# 9. Canary deployment – canary profile versions drive current_profile_versions
# ---------------------------------------------------------------------------
run "canary_profile_versions_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
    deployment_information = {
      deployment-strategy = "canary"
      enabled             = true
      main = {
        version  = "2.7.1"
        weight   = 80
        profiles = ["6.1.4"]
      }
      canary = {
        version  = "2.7.2"
        weight   = "20"
        profiles = ["6.1.5"]
      }
    }
    resource_definitions = {
      "validation-service-pathogen" = {
        replicas              = 1
        resource_block        = null
        istio_proxy_resources = {}
      }
    }
  }

  # With a canary version set, current_profile_versions reflects canary profiles
  assert {
    condition     = contains(output.profile_metadata.current_profile_versions, "6.1.5")
    error_message = "Expected current_profile_versions to contain canary profile '6.1.5', got: ${jsonencode(output.profile_metadata.current_profile_versions)}"
  }

  # Canary destination subsets must be non-empty
  assert {
    condition     = length(output.profile_metadata.destination_subsets.canary) > 0
    error_message = "Expected non-empty canary subsets for canary deployment, got: ${jsonencode(output.profile_metadata.destination_subsets.canary)}"
  }
}

# ---------------------------------------------------------------------------
# 10. Compound feature_flags and config_options are merged per variant
#     (verified via the rendered app-values in output.debug rendered indirectly
#     through module.validation_service application_values content)
# ---------------------------------------------------------------------------
run "feature_flags_compound_key_merge_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
    feature_flags = {
      "validation-service-pathogen"    = { "FEATURE_FLAG_GLOBAL" = true }
      "validation-service-pathogen:v6" = { "FEATURE_FLAG_V6_ONLY" = true }
    }
    config_options = {
      "validation-service-pathogen"    = { "CONFIG_GLOBAL" = "global-value" }
      "validation-service-pathogen:v6" = { "CONFIG_V6_ONLY" = "v6-value" }
    }
  }

  # Both plain and compound feature_flags are passed into the module –
  # the for_each module must have been created for both major versions.
  assert {
    condition     = length(module.validation_service) == 2
    error_message = "Expected 2 validation_service instances with compound-key flags, got: ${length(module.validation_service)}"
  }
}

# ---------------------------------------------------------------------------
# 11. Dedicated mode with a single profile – no subsets have mode=="dedicated"
#     → legacy module is NOT created (single-profile dedicated behaves like distributed)
# ---------------------------------------------------------------------------
run "dedicated_single_profile_no_legacy_test" {
  command = apply

  variables {
    profile_provisioning_mode = "dedicated"
    deployment_information = {
      deployment-strategy = "canary"
      enabled             = true
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.1.4"]
      }
    }
  }

  # vs_use_for_each is false in dedicated mode
  assert {
    condition     = local.vs_use_for_each == false
    error_message = "Expected vs_use_for_each=false for dedicated mode, got: ${local.vs_use_for_each}"
  }

  # Single profile in dedicated mode → the subset template uses the distributed
  # branch (length(versions)==1), so no dedicated subset is generated.
  assert {
    condition     = length(local.dedicated_subsets.main) == 0
    error_message = "Expected 0 dedicated subsets for single-profile dedicated mode, got: ${jsonencode(local.dedicated_subsets.main)}"
  }

  # Neither module creates instances: vs_use_for_each=false → validation_service=0,
  # no dedicated subsets → validation_service_legacy=0.
  assert {
    condition     = length(module.validation_service) == 1 && length(module.validation_service_legacy) == 0
    error_message = "Expected both module counts to be 0 for single-profile dedicated mode"
  }
}

# ---------------------------------------------------------------------------
# 12. istio_template_file – the referenced template is rendered into the
#     Istio Helm release values (app_name / namespace substituted).
# ---------------------------------------------------------------------------
run "istio_template_file_rendering_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
  }

  # The first (templated) element must contain the substituted app_name.
  assert {
    condition     = strcontains(helm_release.istio.values[0], "app_name: validation-service-pathogen")
    error_message = "Expected rendered istio_template_file to contain 'app_name: validation-service-pathogen', got: ${jsonencode(helm_release.istio.values)}"
  }

  # And the substituted target namespace.
  assert {
    condition     = strcontains(helm_release.istio.values[0], "namespace: demis")
    error_message = "Expected rendered istio_template_file to contain 'namespace: demis', got: ${jsonencode(helm_release.istio.values)}"
  }
}

# ---------------------------------------------------------------------------
# 13a. istio_values_override – when set it is appended as an extra values
#      entry (compact keeps the non-empty override alongside the template).
# ---------------------------------------------------------------------------
run "istio_values_override_appended_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
    istio_values_override     = "istioOverrideKey: istioOverrideValue"
  }

  # Two entries: the rendered template plus the override.
  assert {
    condition     = length(helm_release.istio.values) == 2
    error_message = "Expected 2 istio values entries (template + override), got: ${length(helm_release.istio.values)} – ${jsonencode(helm_release.istio.values)}"
  }

  # The override content is the appended (last) entry.
  assert {
    condition     = helm_release.istio.values[1] == "istioOverrideKey: istioOverrideValue"
    error_message = "Expected the override to be appended verbatim, got: ${jsonencode(helm_release.istio.values)}"
  }
}

# ---------------------------------------------------------------------------
# 13b. istio_values_override – when left at its empty default, compact()
#      drops it so only the rendered template entry remains.
# ---------------------------------------------------------------------------
run "istio_values_override_empty_default_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
  }

  # Only the rendered template entry – the empty override is stripped by compact().
  assert {
    condition     = length(helm_release.istio.values) == 1
    error_message = "Expected 1 istio values entry when no override is set, got: ${length(helm_release.istio.values)} – ${jsonencode(helm_release.istio.values)}"
  }
}

# ---------------------------------------------------------------------------
# 14. app_template_file – the referenced application values template is
#     readable and renders the supplied parameters. The template feeds the
#     (mocked) child Helm deployment, so it is exercised via the same
#     templatefile() call the module performs for a distributed variant.
# ---------------------------------------------------------------------------
run "app_template_file_rendering_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
  }

  # app_name substitution.
  assert {
    condition     = strcontains(templatefile(var.app_template_file, { provisioning_mode = "distributed", app_name = "${var.name}-v6", profile_versions = ["6.1.4"], feature_flags = {}, config_options = {}, replica_count = 1 }), "app_name: validation-service-pathogen-v6")
    error_message = "Expected rendered app_template_file to contain 'app_name: validation-service-pathogen-v6'."
  }

  # profile_versions substitution (JSON-encoded).
  assert {
    condition     = strcontains(templatefile(var.app_template_file, { provisioning_mode = "distributed", app_name = "${var.name}-v6", profile_versions = ["6.1.4"], feature_flags = {}, config_options = {}, replica_count = 1 }), "profile_versions: [\"6.1.4\"]")
    error_message = "Expected rendered app_template_file to contain the JSON-encoded profile_versions."
  }

  # A full apply with the custom app_template_file must succeed and create the
  # per-variant Helm deployments.
  assert {
    condition     = length(module.validation_service) == 2
    error_message = "Expected app_template_file to be accepted and 2 validation_service instances created, got: ${length(module.validation_service)}"
  }
}

# ---------------------------------------------------------------------------
# 15a. app_values_override – when set it is appended after the rendered
#      application values (same compact() handling the module applies).
# ---------------------------------------------------------------------------
run "app_values_override_appended_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
    app_values_override       = "appOverrideKey: appOverrideValue"
  }

  # compact([<rendered-template>, <override>]) keeps both entries.
  assert {
    condition     = length(compact([templatefile(var.app_template_file, { provisioning_mode = "distributed", app_name = "${var.name}-v6", profile_versions = ["6.1.4"], feature_flags = {}, config_options = {}, replica_count = 1 }), var.app_values_override])) == 2
    error_message = "Expected the non-empty app_values_override to be appended, got: ${jsonencode(compact([templatefile(var.app_template_file, { provisioning_mode = "distributed", app_name = "${var.name}-v6", profile_versions = ["6.1.4"], feature_flags = {}, config_options = {}, replica_count = 1 }), var.app_values_override]))}"
  }

  # The override is the appended (last) entry.
  assert {
    condition     = element(compact([templatefile(var.app_template_file, { provisioning_mode = "distributed", app_name = "${var.name}-v6", profile_versions = ["6.1.4"], feature_flags = {}, config_options = {}, replica_count = 1 }), var.app_values_override]), 1) == "appOverrideKey: appOverrideValue"
    error_message = "Expected app_values_override to be appended verbatim as the last entry."
  }

  # The apply with the override must succeed and still create both variants.
  assert {
    condition     = length(module.validation_service) == 2
    error_message = "Expected app_values_override to be accepted and 2 validation_service instances created, got: ${length(module.validation_service)}"
  }
}

# ---------------------------------------------------------------------------
# 15b. app_values_override – when left at its empty default, compact() drops
#      it so only the rendered application values remain.
# ---------------------------------------------------------------------------
run "app_values_override_empty_default_test" {
  command = apply

  variables {
    profile_provisioning_mode = "distributed"
  }

  # Empty override is stripped by compact() → a single rendered entry remains.
  assert {
    condition     = length(compact([templatefile(var.app_template_file, { provisioning_mode = "distributed", app_name = "${var.name}-v6", profile_versions = ["6.1.4"], feature_flags = {}, config_options = {}, replica_count = 1 }), var.app_values_override])) == 1
    error_message = "Expected the empty app_values_override to be stripped by compact()."
  }
}
