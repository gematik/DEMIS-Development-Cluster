# Based on Istio Addon - https://github.com/istio/istio/blob/1.17.2/samples/addons/grafana.yaml
locals {
  app     = "grafana"
  version = var.grafana_version
  digest  = var.grafana_digest
  port    = 3000
}

resource "kubernetes_config_map_v1" "grafana_config" {
  metadata {
    name      = local.app
    namespace = var.target_namespace
    labels = {
      "app"       = local.app
      "component" = local.app
      "release"   = local.version
    }
  }

  data = {
    allow-snippet-annotations = "false"
    "grafana.ini"             = file("${path.module}/config/grafana.ini")
    "datasources.yaml"        = file("${path.module}/config/datasources.yaml")
    "dashboardproviders.yaml" = file("${path.module}/config/dashboardproviders.yaml")
  }
}

resource "kubernetes_config_map_v1" "grafana_istio_dashboards" {
  metadata {
    name      = "istio-grafana-dashboards"
    namespace = var.target_namespace
    labels = {
      "app"       = local.app
      "component" = local.app
      "release"   = local.app
    }
  }

  data = {
    "istio-performance-dashboard.json" = data.local_file.istio_performance_dashboard.content
    "pilot-dashboard.json"             = data.local_file.istio_control_plane_dashboard.content
  }

  lifecycle {
    precondition {
      condition     = !contains([data.local_file.istio_performance_dashboard.filename, data.local_file.istio_control_plane_dashboard.filename], ".gitkeep")
      error_message = "one or more of the dashboard files are missing."
    }
  }
}


resource "kubernetes_config_map_v1" "grafana_istio_services_dashboards" {
  metadata {
    name      = "istio-services-grafana-dashboards"
    namespace = var.target_namespace
    labels = {
      "app"       = local.app
      "component" = local.app
      "release"   = local.app
    }
  }

  data = {
    "istio-extension-dashboard.json" = data.local_file.istio_wasm_dashboard.content
    "istio-mesh-dashboard.json"      = data.local_file.istio_mesh_dashboard.content
    "istio-service-dashboard.json"   = data.local_file.istio_service_dashboard.content
    "istio-workload-dashboard.json"  = data.local_file.istio_workload_dashboard.content
  }

  lifecycle {
    precondition {
      condition     = !contains([data.local_file.istio_wasm_dashboard.filename, data.local_file.istio_mesh_dashboard.filename, data.local_file.istio_service_dashboard.filename, data.local_file.istio_workload_dashboard.filename], ".gitkeep")
      error_message = "one or more of the dashboard files are missing."
    }
  }
}

resource "kubernetes_config_map_v1" "grafana_base_dashboards" {
  metadata {
    name      = "base-grafana-dashboards"
    namespace = var.target_namespace
    labels = {
      "app"       = local.app
      "component" = local.app
      "release"   = local.app
    }
  }

  data = {
    "cluster-dashboard.json"   = data.local_file.cluster_dashboard.content
    "cluster-monitoring.json"  = data.local_file.cluster_monitoring_prometheus.content
    "pod-metrics.json"         = data.local_file.pod_metrics_dashboard.content
    "prometheus-stats.json"    = data.local_file.prometheus_stats.content
    "prometheus-overview.json" = data.local_file.prometheus_overview.content
  }

  lifecycle {
    precondition {
      condition     = !contains([data.local_file.cluster_dashboard.filename, data.local_file.cluster_monitoring_prometheus.filename, data.local_file.pod_metrics_dashboard.filename, data.local_file.prometheus_stats.filename, data.local_file.prometheus_overview.filename], ".gitkeep")
      error_message = "one or more of the dashboard files are missing."
    }
  }
}
