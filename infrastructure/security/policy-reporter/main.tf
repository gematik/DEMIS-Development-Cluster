resource "helm_release" "policy_reporter" {
  name       = "policy-reporter"
  chart      = "policy-reporter"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = var.namespace
  lint       = true
  atomic     = true
  wait       = true

  set {
    name  = "ui.enabled"
    value = true
  }

  set {
    name  = "ui.plugins.kyverno"
    value = true
  }

  set {
    name  = "kyvernoPlugin.enabled"
    value = true
  }
}