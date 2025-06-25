resource "helm_release" "kyverno" {
  name       = "kyverno"
  chart      = "kyverno"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = var.namespace
  lint       = true
  atomic     = true
  wait       = true

  set {
    name  = "admissionController.replicas"
    value = var.admissioncontroller_replicas
  }

  set {
    name  = "backgroundController.replicas"
    value = var.backgroundcontroller_replicas
  }

  set {
    name  = "cleanupController.replicas"
    value = var.cleanupcontroller_replicas
  }

  set {
    name  = "reportsController.replicas"
    value = var.reportscontroller_replicas
  }

  set_list {
    name  = "existingImagePullSecrets"
    value = var.pull_secrets
  }
}