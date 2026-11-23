locals {
  prometheus_name = "prometheus"
  # Local only (monitoring stack of the mesh), enabled in the active-versions.yaml
  prometheus_deployment_information = try(var.deployment_information[local.prometheus_name], { main = { version = "0.0.0" }, enabled = false })
  prometheus_enabled                = try(local.prometheus_deployment_information.enabled, false)
  prometheus_port                   = 9090
  # Cluster-internal URL (Grafana datasource, Kiali)
  prometheus_service_url = "http://${local.prometheus_name}.${var.target_namespace}.svc.cluster.local:${local.prometheus_port}"
}

resource "helm_release" "prometheus" {
  # Local only (monitoring stack of the mesh)
  count = local.prometheus_enabled ? 1 : 0

  name            = local.prometheus_name
  repository      = coalesce(var.helm_repository_by_key.prometheus, "https://prometheus-community.github.io/helm-charts")
  chart           = "prometheus"
  namespace       = var.target_namespace
  version         = coalesce(try(local.prometheus_deployment_information.canary.version, null), local.prometheus_deployment_information.main.version)
  max_history     = 3
  wait            = true
  lint            = true
  atomic          = true
  wait_for_jobs   = true
  cleanup_on_fail = true

  values = [
    file("${path.module}/${local.prometheus_name}/chart-values.yml"),
    # Replicas, resources and sidecar resources (resources.tfvars)
    templatefile("${path.module}/${local.prometheus_name}/resource-values.tftpl.yaml", {
      # Output of the resources module, kube-state-metrics and node-exporter only if set in the resources.tfvars
      server             = var.resource_definitions["prometheus"]
      kube_state_metrics = try(var.resource_definitions["kube-state-metrics"], null)
      node_exporter      = try(var.resource_definitions["prometheus-node-exporter"], null)
    })
  ]
}

# Scraping the kubelet (cAdvisor) through the API server proxy
resource "kubernetes_cluster_role_v1" "prometheus_node_proxy" {
  count = local.prometheus_enabled ? 1 : 0

  metadata { name = "${local.prometheus_name}-node-proxy" }
  rule {
    api_groups = [""]
    resources  = ["nodes/proxy"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "prometheus_node_proxy" {
  count = local.prometheus_enabled ? 1 : 0

  metadata { name = "${local.prometheus_name}-node-proxy" }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.prometheus_node_proxy[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.prometheus_name
    namespace = var.target_namespace
  }
}
