resource "kubernetes_secret_v1" "kiali_service_account_token" {
  metadata {
    name      = "${local.app}-service-account-token"
    namespace = var.target_namespace
    labels = {
      "app"                        = local.app
      "component"                  = local.app
      "release"                    = local.version
      "app.kubernetes.io/instance" = local.app
      "app.kubernetes.io/name"     = local.app
      "app.kubernetes.io/part-of"  = local.app
      "app.kubernetes.io/version"  = var.kiali_version
    }

    annotations = {
      "kubernetes.io/service-account.name" = local.app
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [helm_release.this]
}
