resource "helm_release" "falco" {
  name       = "falco"
  chart      = "falco"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = var.namespace
  lint       = true
  atomic     = true
  wait       = true

  set {
    name  = "collectors.kubernetes.enabled"
    value = var.kubernetes_meta_collector
  }

  set {
    name  = "falcosidekick.enabled"
    value = var.falcosidekick_enabled
  }

  set {
    name  = "falcosidekick.webui.enabled"
    value = var.falcosidekick_ui_enabled
  }

  set {
    name  = "driver.kind"
    value = var.driver_kind
  }

}
