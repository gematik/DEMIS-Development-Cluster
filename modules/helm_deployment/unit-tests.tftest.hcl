# Mock the Helm provider so no charts are fetched from remote repositories.
# This keeps plan-time assertions fast and fully offline.
mock_provider "helm" {}

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
    application_values = [<<EOT
    image:
      pullPolicy: Always
    extraEnvVars:
      - name: LOG_LEVEL
        value: error
    EOT
    ]
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
    condition     = yamldecode(helm_release.chart["1.8.3"].values[0]).image.tag == "1.8.3"
    error_message = "Expected the image tag at the property 'image.tag', got ${jsonencode(helm_release.chart["1.8.3"].values)}"
  }
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

    application_values = [<<EOF
    extraEnvVars:
      - name: LOG_LEVEL
        value: error
    EOF
    ]
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
    application_values = [<<EOF
    extraEnvVars:
      - name: LOG_LEVEL
        value: error
    EOF
    ]
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

# Canary Deployment with digests: the canary version is deployed pinned by its digest, the main version is not changed
run "helm_deployment_canary_digest_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "required.image.tag"
      helm_repository               = "https://gematik.github.io/DEMIS-Helm-Charts/"
    }

    application_name = "futs-ars"
    deployment_information = {
      chart-name          = "futs"
      deployment-strategy = "canary"
      enabled             = true
      main = {
        version      = "2.8.2"
        image-digest = "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        weight       = 100
      }
      canary = {
        version      = "2.8.3"
        image-digest = "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
        weight       = 0
      }
    }
  }

  # the main version reuses its deployed values including the image, it is not updated by the canary deployment
  assert {
    condition     = helm_release.chart["2.8.2"].reuse_values && length(helm_release.chart["2.8.2"].values) == 0
    error_message = "Expected the main version to reuse its values without setting the image, got ${jsonencode(helm_release.chart["2.8.2"].values)}"
  }
  assert {
    condition     = yamldecode(helm_release.chart["2.8.3"].values[0]).required.image.tag == "2.8.3@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    error_message = "Expected the canary version to be pinned by its digest, got ${jsonencode(helm_release.chart["2.8.3"].values)}"
  }
  # the version of the release stays the plain tag
  assert {
    condition     = helm_release.chart["2.8.3"].version == "2.8.3"
    error_message = "Expected the chart version to stay '2.8.3', got ${helm_release.chart["2.8.3"].version}"
  }
}

# Replace Deployment with a canary version: the digest of the canary version is deployed
run "helm_deployment_replace_canary_digest_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "required.image.tag"
      helm_repository               = "https://gematik.github.io/DEMIS-Helm-Charts/"
    }

    application_name = "ars-purger"
    deployment_information = {
      deployment-strategy = "replace"
      enabled             = true
      main = {
        version      = "1.6.1"
        image-digest = "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        weight       = 100
      }
      canary = {
        version      = "1.6.2"
        image-digest = "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
        weight       = 0
      }
    }
  }

  assert {
    condition     = yamldecode(helm_release.chart["1.6.2"].values[0]).required.image.tag == "1.6.2@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    error_message = "Expected the canary version to be pinned by its digest, got ${jsonencode(helm_release.chart["1.6.2"].values)}"
  }
}

# Rolling Deployment with image tag override: the digest is appended to the image tag
run "helm_deployment_rolling_image_tag_digest_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "required.image.tag"
      helm_repository               = "https://gematik.github.io/DEMIS-Helm-Charts/"
    }

    application_name = "ars-purger"
    deployment_information = {
      image-tag           = "1.6.2-hotfix"
      deployment-strategy = "rolling"
      enabled             = true
      main = {
        version      = "1.6.2"
        image-digest = "sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
        weight       = 100
      }
    }
  }

  assert {
    condition     = yamldecode(helm_release.chart["rolling"].values[0]).required.image.tag == "1.6.2-hotfix@sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
    error_message = "Expected the image tag override to be pinned by digest, got ${jsonencode(helm_release.chart["rolling"].values)}"
  }
}

# A digest in an invalid format is rejected
run "helm_deployment_invalid_digest_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "required.image.tag"
      helm_repository               = "https://gematik.github.io/DEMIS-Helm-Charts/"
    }

    application_name = "ars-purger"
    deployment_information = {
      deployment-strategy = "replace"
      enabled             = true
      main = {
        version      = "1.6.2"
        image-digest = "1.6.2@sha256:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
        weight       = 100
      }
    }
  }

  expect_failures = [var.deployment_information]
}

# Without digest the plain tag is deployed
run "helm_deployment_without_digest_test" {
  command = plan

  variables {
    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "required.image.tag"
      helm_repository               = "https://gematik.github.io/DEMIS-Helm-Charts/"
    }

    application_name = "ars-purger"
    deployment_information = {
      deployment-strategy = "replace"
      enabled             = true
      main = {
        version = "1.6.2"
        weight  = 100
      }
    }
  }

  assert {
    condition     = yamldecode(helm_release.chart["1.6.2"].values[0]).required.image.tag == "1.6.2"
    error_message = "Expected the plain image tag, got ${jsonencode(helm_release.chart["1.6.2"].values)}"
  }
}
