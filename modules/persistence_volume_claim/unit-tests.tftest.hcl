provider "kubernetes" {
  config_path = "${path.module}/.test_kubeconfig"
}

# Test creation of a valid PVC in the "demis" Namespace
run "demis_pvc_test" {
  command = plan

  variables {
    namespace     = "demis"
    name          = "postgres-volume-claim"
    storage_class = "standard"
    capacity      = "1Gi"
    access_mode   = "ReadWriteMany"
  }

  # assert that the Namespace is created with the input variable
  assert {
    condition     = output.metadata.namespace == var.namespace
    error_message = "The PVC Namespace was not created with the expected namespace, got: ${output.metadata.namespace}"
  }

  # assert that the Name of the PVC reflects the input variable
  assert {
    condition     = output.metadata.name == var.name
    error_message = "The PVC Namespace was not created with the expected name, got: ${output.metadata.namespace}"
  }

  # validate tha the internal values of PVC are correctly set
  assert {
    condition     = kubernetes_persistent_volume_claim_v1.this.spec[0].storage_class_name == var.storage_class
    error_message = "The PVC has a wrong storage class."
  }

  # validate tha the internal values of PVC are correctly set
  assert {
    condition     = kubernetes_persistent_volume_claim_v1.this.spec[0].resources[0].requests.storage == var.capacity
    error_message = "The PVC has a wrong value for the storage capacity."
  }

  # validate tha the internal values of PVC are correctly set
  assert {
    condition     = contains(kubernetes_persistent_volume_claim_v1.this.spec[0].access_modes, var.access_mode)
    error_message = "The PVC has an unexpected access mode."
  }
}

# Test creation of a valid PVC in the "demis" Namespace
run "demis_pvc_test_2" {
  command = plan

  variables {
    namespace     = "demis"
    name          = "keycloak-volume-claim"
    storage_class = "demis-storage-delete"
    capacity      = "20Mi"
    access_mode   = "ReadWriteOnce"
    labels = {
      "app" : "keycloak"
    }
  }

  # assert that the Namespace is created with the input variable
  assert {
    condition     = output.metadata.namespace == var.namespace
    error_message = "The PVC Namespace was not created with the expected namespace, got: ${output.metadata.namespace}"
  }

  # assert that the Name of the PVC reflects the input variable
  assert {
    condition     = output.metadata.name == var.name
    error_message = "The PVC Namespace was not created with the expected name, got: ${output.metadata.namespace}"
  }

  # validate tha the internal values of PVC are correctly set
  assert {
    condition     = kubernetes_persistent_volume_claim_v1.this.metadata[0].labels == tomap(var.labels)
    error_message = "The PVC Namespace was not created with the expected labels, got: ${join(",", keys(kubernetes_persistent_volume_claim_v1.this.metadata[0].labels))}"
  }

  # validate tha the internal values of PVC are correctly set
  assert {
    condition     = kubernetes_persistent_volume_claim_v1.this.spec[0].storage_class_name == var.storage_class
    error_message = "The PVC has a wrong storage class."
  }

  # validate tha the internal values of PVC are correctly set
  assert {
    condition     = kubernetes_persistent_volume_claim_v1.this.spec[0].resources[0].requests.storage == var.capacity
    error_message = "The PVC has a wrong value for the storage capacity."
  }

  # validate tha the internal values of PVC are correctly set
  assert {
    condition     = contains(kubernetes_persistent_volume_claim_v1.this.spec[0].access_modes, var.access_mode)
    error_message = "The PVC has an unexpected access mode."
  }
}

run "demis_invalid_storage_class_test" {
  command = plan

  variables {
    namespace     = "demis"
    name          = "keycloak-volume-claim"
    storage_class = "not-existing-class"
    capacity      = "100Mi"
    access_mode   = "ReadWriteOnce"
  }

  expect_failures = [var.storage_class]
}

run "demis_invalid_capacity_test" {
  command = plan

  variables {
    namespace     = "demis"
    name          = "keycloak-volume-claim"
    storage_class = "standard"
    capacity      = "100Ki"
    access_mode   = "ReadWriteOnce"
  }

  expect_failures = [var.capacity]
}

run "demis_invalid_access_mode_test" {
  command = plan

  variables {
    namespace     = "demis"
    name          = "keycloak-volume-claim"
    storage_class = "standard"
    capacity      = "100Mi"
    access_mode   = "BadAccessMode"
  }

  expect_failures = [var.access_mode]
}

