resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = local.app
    namespace = var.target_namespace
    labels = {
      "app"       = local.app
      "component" = local.app
      "release"   = local.app
    }
  }
}
