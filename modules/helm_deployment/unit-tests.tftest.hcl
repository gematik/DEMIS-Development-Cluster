# Test Canary Deployment of two versions of the same application, no istio
run "helm_deployment_canary_with_istio_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "image.tag"
      helm_repository               = "https://gematik.github.io/DEMIS-Helm-Charts/"
      istio_routing_chart_version   = "1.1.0"
      deployment_timeout            = 300
    }

    application_name = "certificate-update-service"
    deployment_information = {
      deployment-strategy = "canary"
      enabled             = true
      main = {
        version = "1.8.2"
        weight  = 100
      }
      canary = {
        version = "1.8.3"
        weight  = 0
      }
    }

    # your custom settings
    application_values = <<EOT
    image:
      pullPolicy: Always
    extraEnvVars:
      - name: LOG_LEVEL
        value: error
    EOT
  }

  # assert that the output versions are correct
  assert {
    condition     = length(output.app_chart_versions) == 2 && output.app_chart_versions[0] == "1.8.2" && output.app_chart_versions[1] == "1.8.3"
    error_message = "Expected where the following versions for the application chart: ${join(",", output.app_chart_versions)}"
  }

  # assert that the Istio Helm Chart is deployed
  assert {
    condition     = output.istio_version == var.helm_settings.istio_routing_chart_version
    error_message = "Expected output.istio_version to be '${nonsensitive(var.helm_settings.istio_routing_chart_version)}' but was: '${output.istio_version}'"
  }

  # Check internal values
  assert {
    condition     = can(regex(".*LOG_LEVEL.*", join(",", helm_release.chart["1.8.3"].values)))
    error_message = "The Helm Chart Application Values are wrong, got ${join(",", helm_release.chart["1.8.3"].values)}"
  }
  assert {
    condition     = helm_release.chart["1.8.3"].namespace == var.namespace
    error_message = "Expected the namespace to be ${var.namespace}, got ${helm_release.chart["1.8.3"].namespace}"
  }
  # check istio values
  assert {
    condition     = helm_release.istio[0].namespace == var.namespace
    error_message = "Expected the namespace to be ${var.namespace}, got ${helm_release.istio[0].namespace}."
  }

  assert {
    condition     = length(helm_release.istio[0].set) == 4
    error_message = "Expected the Istio Helm Chart to have exactly 4 set values, got ${length(helm_release.istio[0].set)}."
  }

  assert {
    condition     = anytrue([for set in helm_release.istio[0].set : (set.name == "destinationSubsets.main.version" && set.value == "1.8.2")])
    error_message = "Expected the Istio Helm Chart to have the correct version '1.8.2' set for the main subset, got ${jsonencode(helm_release.istio[0].set)}."
  }

  assert {
    condition     = anytrue([for set in helm_release.istio[0].set : (set.name == "destinationSubsets.main.weight" && set.value == "100")])
    error_message = "Expected the Istio Helm Chart to have the correct weight '100' set for the main subset, got ${jsonencode(helm_release.istio[0].set)}."
  }

  assert {
    condition     = anytrue([for set in helm_release.istio[0].set : (set.name == "destinationSubsets.canary.version" && set.value == "1.8.3")])
    error_message = "Expected the Istio Helm Chart to have the correct version '1.8.3' set for the canary subset, got ${jsonencode(helm_release.istio[0].set)}."
  }

  assert {
    condition     = anytrue([for set in helm_release.istio[0].set : (set.name == "destinationSubsets.canary.weight" && set.value == "0")])
    error_message = "Expected the Istio Helm Chart to have the correct weight '0' set for the canary subset, got ${jsonencode(helm_release.istio[0].set)}."
  }
}

# Test Canary Deployment of a single version of the application, no istio
run "helm_deployment_canary_no_istio_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "image.tag"
      helm_repository               = "https://gematik.github.io/DEMIS-Helm-Charts/"
    }

    application_name = "certificate-update-service"
    deployment_information = {
      deployment-strategy = "canary"
      enabled             = true
      main = {
        version = "1.8.3"
        weight  = 100
      }
    }

    application_values = <<EOF
    extraEnvVars:
      - name: LOG_LEVEL
        value: error
    EOF
  }

  # assert that the versions are correct
  assert {
    condition     = length(output.app_chart_versions) == 1 && output.app_chart_versions[0] == "1.8.3"
    error_message = "Expected was the version 1.8.3"
  }

  assert {
    condition     = output.istio_version == null
    error_message = "The Istio Helm Chart should be null (not deployed)"
  }

  # Check internal values
  assert {
    condition     = length(helm_release.chart["1.8.3"].values) > 0 && can(regex(".*LOG_LEVEL.*", join(",", helm_release.chart["1.8.3"].values)))
    error_message = "Expected the values to contain the word 'LOG_LEVEL', got ${join(",", helm_release.chart["1.8.3"].values)}"
  }

  assert {
    condition     = helm_release.chart["1.8.3"].namespace == var.namespace
    error_message = "Expected the namespace to be ${var.namespace}, got ${helm_release.chart["1.8.3"].namespace}"
  }

  assert {
    condition     = length(helm_release.chart) == 1 && length(helm_release.istio) == 0
    error_message = "Expected only one Helm Release for the application and none for Istio, got ${length(helm_release.chart)} application charts and ${length(helm_release.istio)} Istio charts."
  }
}

run "helm_deployment_replace_or_update_test_without_istio_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "image.tag"
      helm_repository               = "https://gematik.github.io/DEMIS-Helm-Charts/"
    }

    application_name = "certificate-update-service"
    deployment_information = {
      deployment-strategy = "replace"
      enabled             = true
      main = {
        version = "1.8.3"
        weight  = 100
      }
    }
  }

  # assert that the output versions are correct
  assert {
    condition     = length(output.app_chart_versions) == 1 && output.app_chart_versions[0] == var.deployment_information.main.version
    error_message = "Expected output.app_chart_versions to be '${var.deployment_information.main.version}' but was: '${join(",", output.app_chart_versions)}'"
  }

  assert {
    condition     = output.istio_version == null
    error_message = "The Istio Helm Chart should be null (not deployed)"
  }

  assert {
    condition     = length(helm_release.chart) == 1 && length(helm_release.istio) == 0
    error_message = "Expected only one Helm Release for the application and none for Istio, got ${length(helm_release.chart)} application charts and ${length(helm_release.istio)} Istio charts."
  }
}

run "helm_deployment_replace_or_update_canary_version_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "image.tag"
      helm_repository               = "https://gematik.github.io/DEMIS-Helm-Charts/"
      istio_routing_chart_version   = "1.1.0"
      deployment_timeout            = 300
    }

    application_name = "certificate-update-service"
    deployment_information = {
      deployment-strategy = "replace"
      enabled             = true
      main = {
        version = "1.8.2"
        weight  = 100
      }
      canary = {
        version = "1.8.3"
        weight  = 0
      }
    }
    application_values = <<EOF
    extraEnvVars:
      - name: LOG_LEVEL
        value: error
    EOF
  }

  # assert that the output versions are correct
  assert {
    condition     = length(output.app_chart_versions) == 1 && output.app_chart_versions[0] == var.deployment_information.canary.version
    error_message = "Expected output.app_chart_versions to be '${var.deployment_information.main.version}' but was: '${join(",", output.app_chart_versions)}'"
  }

  # assert that the Istio Helm Chart is deployed
  assert {
    condition     = output.istio_version == var.helm_settings.istio_routing_chart_version
    error_message = "Expected output.istio_version to be '${nonsensitive(var.helm_settings.istio_routing_chart_version)}' but was: '${output.istio_version}'"
  }

  # Check internal values
  assert {
    condition     = can(regex(".*LOG_LEVEL.*", join(",", helm_release.chart["1.8.3"].values)))
    error_message = "The Helm Chart Application Values are wrong, got ${join(",", helm_release.chart["1.8.3"].values)}^"
  }

  assert {
    condition     = helm_release.chart["1.8.3"].namespace == var.namespace
    error_message = "Expected the namespace to be ${var.namespace}, got ${helm_release.chart["1.8.3"].namespace}"
  }

  # check istio values
  assert {
    condition     = helm_release.istio[0].namespace == var.namespace
    error_message = "Expected the namespace to be ${var.namespace}, got ${helm_release.istio[0].namespace}."
  }

  assert {
    condition     = length(helm_release.istio[0].set) == 2
    error_message = "Expected the Istio Helm Chart to have exactly 4 set values, got ${length(helm_release.istio[0].set)}."
  }

  assert {
    condition     = anytrue([for set in helm_release.istio[0].set : (set.name == "destinationSubsets.main.version" && set.value == "1.8.3")])
    error_message = "Expected the Istio Helm Chart to have the correct version '1.8.2' set for the main subset, got ${jsonencode(helm_release.istio[0].set)}."
  }

  assert {
    condition     = anytrue([for set in helm_release.istio[0].set : (set.name == "destinationSubsets.main.weight" && set.value == "100")])
    error_message = "Expected the Istio Helm Chart to have the correct weight '100' set for the main subset, got ${jsonencode(helm_release.istio[0].set)}."
  }
}
