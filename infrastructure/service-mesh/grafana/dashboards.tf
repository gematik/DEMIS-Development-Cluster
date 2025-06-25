# Perform the download of Grafana Dahsboards based on istio version
resource "terraform_data" "dashboard_downloader" {

  triggers_replace = {
    istio_version = var.istio_version
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/dashboards"
    command     = "sh ./downloader.sh ${var.istio_version}"
  }
}

#
# Identitfy the downloaded Dashboards and use them as source for the ConfigMaps
#
# Istio Dashboards
data "local_file" "istio_mesh_dashboard" {
  filename   = "${path.module}/dashboards/Istio-Mesh-Dashboard.json"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "istio_workload_dashboard" {
  filename   = "${path.module}/dashboards/Istio-Workload-Dashboard.json"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "istio_service_dashboard" {
  filename   = "${path.module}/dashboards/Istio-Service-Dashboard.json"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "istio_control_plane_dashboard" {
  filename   = "${path.module}/dashboards/Istio-Control-Plane-Dashboard.json"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "istio_wasm_dashboard" {
  filename   = "${path.module}/dashboards/Istio-Wasm-Extension-Dashboard.json"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "istio_performance_dashboard" {
  filename   = "${path.module}/dashboards/Istio-Performance-Dashboard.json"
  depends_on = [terraform_data.dashboard_downloader]
}

# Core Dashboards
data "local_file" "cluster_dashboard" {
  filename   = "${path.module}/dashboards/Kubernetes-Cluster.json"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "cluster_monitoring_prometheus" {
  filename   = "${path.module}/dashboards/Kubernetes-cluster-monitoring-via-Prometheus.json"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "pod_metrics_dashboard" {
  filename   = "${path.module}/dashboards/Kubernetes-Pod-Metrics.json"
  depends_on = [terraform_data.dashboard_downloader]
}


data "local_file" "prometheus_stats" {
  filename   = "${path.module}/dashboards/Prometheus-Stats.json"
  depends_on = [terraform_data.dashboard_downloader]
}

data "local_file" "prometheus_overview" {
  filename   = "${path.module}/dashboards/Prometheus-20-Overview.json"
  depends_on = [terraform_data.dashboard_downloader]
}
