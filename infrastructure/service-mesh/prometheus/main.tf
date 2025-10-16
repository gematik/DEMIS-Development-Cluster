locals {
  app     = "prometheus"
  version = var.prometheus_version
  port    = 9090
}

resource "helm_release" "this" {
  name            = local.app
  repository      = var.prometheus_helm_repository
  chart           = "prometheus"
  namespace       = var.target_namespace
  version         = local.version
  max_history     = 3
  wait            = true
  lint            = true
  atomic          = true
  wait_for_jobs   = true
  cleanup_on_fail = true

  values = [file("${abspath(path.module)}/chart-values.yml")]
}
