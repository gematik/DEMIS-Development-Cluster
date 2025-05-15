resource "kubernetes_persistent_volume_claim_v1" "this" {
  metadata {
    name        = var.name
    namespace   = var.namespace
    labels      = var.labels
    annotations = var.annotations
  }

  spec {
    access_modes = [var.access_mode]
    resources {
      requests = {
        storage = var.capacity
      }
    }
    storage_class_name = var.storage_class
  }

  # Doesn't wait until the PVC is bound by some Pod
  wait_until_bound = var.wait_until_bound
}
