provider "kubernetes" {
  config_path = "${path.module}/.test_kubeconfig"
}

# Test Namespace with Istio Injection
run "demis_namespace_istio_test" {
  command = plan

  variables {
    name                   = "demis"
    enable_istio_injection = true
  }

  # assert that the Namespace is created with the correct name
  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].name == var.name
    error_message = "The Name of the Kubernetes Namespace is not correct."
  }

  # assert that the Namespace is created in the correct label for Istio
  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].labels["istio-injection"] == "enabled"
    error_message = "The Namespace has an invalid label value for the istio injection."
  }

  # assert that output is correct
  assert {
    condition     = output.name == var.name
    error_message = "The Name of the Kubernetes Namespace is not correct."
  }

  # assert that output is correct
  assert {
    condition     = output.labels["istio-injection"] == "enabled"
    error_message = "The Namespace has an invalid label value for the istio injection."
  }

  # assert that output is correct
  assert {
    condition     = length(output.labels) == 1
    error_message = "The Namespace has an invalid number of values. This should be 1."
  }

  # assert that output is correct
  assert {
    condition     = length(output.annotations) == 0
    error_message = "The Namespace has invalid annotations. This should be 0."
  }
}

# Test Namespace without Istio Injection and custom labels and annotations
run "demis_namespace_annotations_test" {
  command = plan

  variables {
    name                   = "test-namespace"
    enable_istio_injection = false
    labels = {
      "my-label" = "test-app"
    }
    annotations = {
      "my-annotation" = "test-app"
    }
  }

  # assert that the Namespace is created with the correct name
  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].name == var.name
    error_message = "The Name of the Kubernetes Namespace is not correct."
  }

  # assert that the Namespace is created in the correct label for Istio
  assert {
    condition     = !contains(keys(kubernetes_namespace_v1.this.metadata[0].labels), "istio-injection")
    error_message = "The Namespace should not contain the the istio injection label."
  }

  # assert that output is correct
  assert {
    condition     = output.name == var.name
    error_message = "The Name of the Kubernetes Namespace is not correct."
  }

  # assert that output is correct
  assert {
    condition     = !contains(keys(output.labels), "istio-injection")
    error_message = "The Namespace should not contain the the istio injection label."
  }

  # assert that output is correct
  assert {
    condition     = contains(keys(output.labels), "my-label") && output.labels["my-label"] == "test-app"
    error_message = "The Namespace has an invalid label value."
  }

  # assert that output is correct
  assert {
    condition     = contains(keys(output.annotations), "my-annotation") && output.annotations["my-annotation"] == "test-app"
    error_message = "The Namespace has an invalid annotation value."
  }
}
