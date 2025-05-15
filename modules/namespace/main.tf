locals {
  # add the istio-injection label to the namespace
  labels = merge(var.labels, var.enable_istio_injection ? { "istio-injection" = "enabled" } : {})
}

# Creates a new Namespace
resource "kubernetes_namespace_v1" "this" {
  metadata {
    name        = var.name
    annotations = var.annotations
    labels      = local.labels
  }
}
