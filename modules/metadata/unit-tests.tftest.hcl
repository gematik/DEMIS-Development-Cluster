provider "kubernetes" {
  config_path = "${path.module}/.test_kubeconfig"
}

# Test Namespace with Istio Injection
run "metadata_test" {
  command = plan

  variables {
    name              = "demis"
    cluster           = "adesso-prod"
    region            = "fra"
    component         = "pvc"
    application       = "postgres"
    organisation_name = "test-orga"
  }

  # assert that the stage is correct
  assert {
    condition     = output.stage == "${var.cluster}-${var.region}"
    error_message = "Expected was ${var.cluster}-${var.region}, got: ${output.stage}"
  }

  # assert that the resource name is correct
  assert {
    condition     = output.resource_name == "${var.application}-${var.component}-${var.cluster}-${var.region}"
    error_message = "Expected was ${var.application}-${var.component}-${var.cluster}-${var.region}, got: ${output.resource_name}"
  }

  # assert that the application tag is correct
  assert {
    condition     = output.tags.application == var.application
    error_message = "Expected was ${var.application}, got: ${output.tags.application}"
  }

  # assert that the organisation tag is correct
  assert {
    condition     = output.tags.organisation == var.organisation_name
    error_message = "Expected was ${var.organisation_name}, got: ${output.tags.organisation}"
  }
}

# Test Namespace with Istio Injection
run "metadata_test_local" {
  command = plan

  variables {
    name              = "demis"
    cluster           = "local"
    region            = "local"
    component         = "pvc"
    application       = "postgres"
    organisation_name = "test-orga"
  }

  # assert that the stage is correct
  assert {
    condition     = output.stage == "${var.cluster}"
    error_message = "Expected was ${var.cluster}, got: ${output.stage}"
  }

  assert {
    condition     = output.resource_name == "${var.application}-${var.component}-${var.cluster}"
    error_message = "Expected was ${var.application}-${var.component}-${var.cluster}, got: ${output.resource_name}"
  }

  assert {
    condition     = output.tags.application == var.application
    error_message = "Expected was ${var.application}, got: ${output.tags.application}"
  }
}

