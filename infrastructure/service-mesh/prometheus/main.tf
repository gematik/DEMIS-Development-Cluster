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

resource "kubernetes_cluster_role_v1" "node_proxy" {
  metadata { name = "${local.app}-node-proxy" }
  rule {
    api_groups = [""]
    resources  = ["nodes/proxy"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "node_proxy" {
  metadata { name = "${local.app}-node-proxy" }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.node_proxy.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.app
    namespace = var.target_namespace
  }
}
