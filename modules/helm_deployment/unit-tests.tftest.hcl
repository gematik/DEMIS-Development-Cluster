# Test Canary Deployment of two versions of the same application, no istio
run "helm_deployment_canary_with_istio_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "image.tag"
      helm_repository               = "https://charts.bitnami.com/bitnami"
      istio_routing_chart_version   = "1.0.0"
      deployment_timeout            = 300
    }

    application_name = "nginx"
    deployment_information = {
      deployment-strategy = "canary"
      enabled             = true
      main = {
        version = "1.26.0"
        weight  = 100
      }
      canary = {
        version = "1.27.0"
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
    condition     = length(output.app_chart_versions) == 2 && output.app_chart_versions[0] == "1.26.0" && output.app_chart_versions[1] == "1.27.0"
    error_message = "Expected where the following versions for the application chart: ${join(",", output.app_chart_versions)}"
  }

  # assert that the Istio Helm Chart is deployed
  assert {
    condition     = output.istio_version == var.helm_settings.istio_routing_chart_version
    error_message = "Expected output.istio_version to be '${nonsensitive(var.helm_settings.istio_routing_chart_version)}' but was: '${output.istio_version}'"
  }

  # Check internal values
  assert {
    condition     = can(regex(".*LOG_LEVEL.*", join(",", helm_release.chart["1.27.0"].values)))
    error_message = "The Helm Chart Application Values are wrong, got ${join(",", helm_release.chart["1.27.0"].values)}^"
  }
}

# Test Canary Deployment of a single version of the application, no istio
run "helm_deployment_canary_no_istio_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "image.tag"
      helm_repository               = "https://charts.bitnami.com/bitnami"
    }

    application_name = "nginx"
    deployment_information = {
      deployment-strategy = "canary"
      enabled             = true
      main = {
        version = "1.27.0"
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
    condition     = length(output.app_chart_versions) == 1 && output.app_chart_versions[0] == "1.27.0"
    error_message = "Expected was the version 1.27.0"
  }

  assert {
    condition     = output.istio_version == null
    error_message = "The Istio Helm Chart should be null (not deployed)"
  }

  # Check internal values
  assert {
    condition     = length(helm_release.chart["1.27.0"].values) > 0 && can(regex(".*LOG_LEVEL.*", join(",", helm_release.chart["1.27.0"].values)))
    error_message = "Expected the values to contain the word 'LOG_LEVEL', got ${join(",", helm_release.chart["1.27.0"].values)}"
  }

  assert {
    condition     = helm_release.chart["1.27.0"].namespace == var.namespace
    error_message = "Expected the namespace to be ${var.namespace}, got ${helm_release.chart["1.27.0"].namespace}"
  }
}

run "helm_deployment_replace_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "image.tag"
      helm_repository               = "https://charts.bitnami.com/bitnami"
    }

    application_name = "postgres"
    deployment_information = {
      deployment-strategy = "replace"
      enabled             = true
      main = {
        version = "1.26.0"
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
}

run "helm_deployment_replace_canary_version_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "image.tag"
      helm_repository               = "https://charts.bitnami.com/bitnami"
      istio_routing_chart_version   = "1.0.0"
      deployment_timeout            = 300
    }

    application_name = "postgres"
    deployment_information = {
      deployment-strategy = "replace"
      enabled             = true
      main = {
        version = "1.26.0"
        weight  = 100
      }
      canary = {
        version = "1.27.0"
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
    condition     = can(regex(".*LOG_LEVEL.*", join(",", helm_release.chart["1.27.0"].values)))
    error_message = "The Helm Chart Application Values are wrong, got ${join(",", helm_release.chart["1.27.0"].values)}^"
  }

  assert {
    condition     = helm_release.chart["1.27.0"].namespace == var.namespace
    error_message = "Expected the namespace to be ${var.namespace}, got ${helm_release.chart["1.27.0"].namespace}"
  }
}
