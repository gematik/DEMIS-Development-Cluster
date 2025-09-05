locals {
  dashboard_folder = "${path.module}/dashboards"
}

# Perform the download of Grafana Dahsboards based on istio version
resource "terraform_data" "dashboard_downloader" {
  triggers_replace = {
    istio_version = var.istio_version
  }
  provisioner "local-exec" {
    working_dir = local.dashboard_folder
    command     = "sh ./downloader.sh ${var.istio_version}"
  }
}

#
# Identitfy the downloaded Dashboards and use them as source for the ConfigMaps
#
# Istio Dashboards
data "local_file" "istio_mesh_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Istio-Mesh-Dashboard.json") ? "${local.dashboard_folder}/Istio-Mesh-Dashboard.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "istio_workload_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Istio-Workload-Dashboard.json") ? "${local.dashboard_folder}/Istio-Workload-Dashboard.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "istio_service_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Istio-Service-Dashboard.json") ? "${local.dashboard_folder}/Istio-Service-Dashboard.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "istio_control_plane_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Istio-Control-Plane-Dashboard.json") ? "${local.dashboard_folder}/Istio-Control-Plane-Dashboard.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "istio_wasm_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Istio-Wasm-Extension-Dashboard.json") ? "${local.dashboard_folder}/Istio-Wasm-Extension-Dashboard.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "istio_performance_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Istio-Performance-Dashboard.json") ? "${local.dashboard_folder}/Istio-Performance-Dashboard.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

# Core Dashboards
data "local_file" "cluster_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Kubernetes-Cluster.json") ? "${local.dashboard_folder}/Kubernetes-Cluster.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "cluster_monitoring_prometheus" {
  filename   = fileexists("${local.dashboard_folder}/Kubernetes-cluster-monitoring-via-Prometheus.json") ? "${local.dashboard_folder}/Kubernetes-cluster-monitoring-via-Prometheus.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "pod_metrics_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Kubernetes-Pod-Metrics.json") ? "${local.dashboard_folder}/Kubernetes-Pod-Metrics.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}


data "local_file" "prometheus_stats" {
  filename   = fileexists("${local.dashboard_folder}/Prometheus-Stats.json") ? "${local.dashboard_folder}/Prometheus-Stats.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "prometheus_overview" {
  filename   = fileexists("${local.dashboard_folder}/Prometheus-20-Overview.json") ? "${local.dashboard_folder}/Prometheus-20-Overview.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}
