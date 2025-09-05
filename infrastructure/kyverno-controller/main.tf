resource "helm_release" "kyverno" {
  name       = "kyverno"
  chart      = "kyverno"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = var.namespace
  lint       = true
  atomic     = true
  wait       = true

  set = [{
    name  = "admissionController.replicas"
    value = var.admissioncontroller_replicas
    },
    {
      name  = "backgroundController.replicas"
      value = var.backgroundcontroller_replicas
    },
    {
      name  = "cleanupController.replicas"
      value = var.cleanupcontroller_replicas
    },
    {
      name  = "reportsController.replicas"
      value = var.reportscontroller_replicas
  }]

  set_list = [{
    name  = "existingImagePullSecrets"
    value = var.pull_secrets
    }
  ]
}
