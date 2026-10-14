locals {
  dashboard_folder = "${path.module}/dashboards"
}

# Perform the download of Grafana Dahsboards based on istio version
resource "terraform_data" "dashboard_downloader" {
  triggers_replace = {
    istio_version = var.istio_version
    downloader    = filesha256("${local.dashboard_folder}/downloader.sh")
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
data "local_file" "prometheus_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Prometheus.json") ? "${local.dashboard_folder}/Prometheus.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "jvm_micrometer_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/JVM-Micrometer.json") ? "${local.dashboard_folder}/JVM-Micrometer.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

# Kubernetes Dashboards
data "local_file" "kubernetes_views_global_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Kubernetes--Views--Global.json") ? "${local.dashboard_folder}/Kubernetes--Views--Global.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "kubernetes_views_namespaces_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Kubernetes--Views--Namespaces.json") ? "${local.dashboard_folder}/Kubernetes--Views--Namespaces.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "kubernetes_views_nodes_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Kubernetes--Views--Nodes.json") ? "${local.dashboard_folder}/Kubernetes--Views--Nodes.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "kubernetes_views_pods_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Kubernetes--Views--Pods.json") ? "${local.dashboard_folder}/Kubernetes--Views--Pods.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "kubernetes_system_api_server_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Kubernetes--System--API-Server.json") ? "${local.dashboard_folder}/Kubernetes--System--API-Server.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "kubernetes_system_coredns_dashboard" {
  filename   = fileexists("${local.dashboard_folder}/Kubernetes--System--CoreDNS.json") ? "${local.dashboard_folder}/Kubernetes--System--CoreDNS.json" : "${local.dashboard_folder}/.gitkeep"
  depends_on = [terraform_data.dashboard_downloader]
}
