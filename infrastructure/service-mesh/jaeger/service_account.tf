resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = local.app
    namespace = var.target_namespace
    labels = {
      "app"                         = local.app
      "app.kubernetes.io/component" = "all-in-one"
    }
  }
}
