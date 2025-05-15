resource "kubernetes_service_v1" "this" {
  metadata {
    name      = local.app
    namespace = var.target_namespace
    labels = {
      "app"       = local.app
      "component" = local.app
      "release"   = local.app
    }
  }
  spec {
    type = "ClusterIP"

    selector = {
      "app"       = local.app
      "component" = local.app
    }

    port {
      name        = "service"
      protocol    = "TCP"
      port        = local.port
      target_port = 3000
    }
  }
}
