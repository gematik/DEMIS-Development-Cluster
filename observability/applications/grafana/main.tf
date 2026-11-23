locals {
  app  = "grafana"
  port = 3000
  # Dashboard ConfigMaps per provider, only with Prometheus (all dashboards are based on Prometheus)
  dashboard_config_maps = var.prometheus_enabled ? {
    istio          = kubernetes_config_map_v1.grafana_istio_dashboards
    istio-services = kubernetes_config_map_v1.grafana_istio_services_dashboards
    base           = kubernetes_config_map_v1.grafana_base_dashboards
    kubernetes     = kubernetes_config_map_v1.grafana_kubernetes_dashboards
    demis          = kubernetes_config_map_v1.grafana_demis_dashboards
  } : {}
  # Grafana folder per provider, the provider name if not listed
  dashboard_folders = { istio-services = "istio" }

  # Datasource credentials as files from the mounted Secrets (read by the datasources with $__file)
  secret_mounts = var.fetched_notifications_datasource != null ? {
    fetched-notifications = {
      secret = var.fetched_notifications_datasource.secret_name
      items  = { user = var.fetched_notifications_datasource.secret_key_user, password = var.fetched_notifications_datasource.secret_key_password }
    }
  } : {}
  secrets_path = "/run/secrets"

  # Replicas, resources and sidecar annotations (resources.tfvars)
  workloads = {
    for name in ["grafana"] : name => {
      replicas  = try(var.resource_definitions[name].replicas, null)
      resources = try(yamldecode(var.resource_definitions[name].resource_block).resources, null)
      annotations = try({
        "sidecar.istio.io/proxyCPU"         = var.resource_definitions[name].istio_proxy_resources.requests.cpu
        "sidecar.istio.io/proxyMemory"      = var.resource_definitions[name].istio_proxy_resources.requests.memory
        "sidecar.istio.io/proxyMemoryLimit" = var.resource_definitions[name].istio_proxy_resources.limits.memory
      }, {})
    }
  }
  # Merged into the chart values (unset values keep the defaults)
  resource_values = { for k, v in {
    replicas  = local.workloads.grafana.replicas
    resources = local.workloads.grafana.resources
  } : k => v if v != null }

  pod_annotations = merge({
    # Prometheus' sidecar does not intercept inbound traffic (plain HTTP), so bypass auto-mTLS
    "traffic.sidecar.istio.io/excludeOutboundPorts" = "9090"
    # Restart on changed dashboards (ConfigMaps outside the chart)
    "checksum/dashboards" = sha256(jsonencode([for name, cm in local.dashboard_config_maps : cm.data]))
  }, local.workloads.grafana.annotations)
}

resource "helm_release" "this" {
  name       = local.app
  repository = var.grafana_helm_repository
  # Pinned by the digest of the OCI chart
  chart           = "grafana@${var.grafana_digest}"
  namespace       = var.target_namespace
  version         = var.grafana_version
  max_history     = 3
  wait            = true
  lint            = true
  atomic          = true
  wait_for_jobs   = true
  cleanup_on_fail = true

  values = [templatefile("${path.module}/config/chart-values.tftpl.yaml", {
    app             = local.app
    port            = local.port
    pod_annotations = local.pod_annotations
    secret_mounts = [for name, mount in local.secret_mounts : {
      name       = "${name}-credentials"
      mountPath  = "${local.secrets_path}/${name}"
      secretName = mount.secret
      readOnly   = true
      items      = [for path, key in mount.items : { key = key, path = path }]
    }]
    datasources = yamldecode(templatefile("${path.module}/config/datasources.tftpl.yaml", {
      prometheus_enabled    = var.prometheus_enabled
      prometheus_url        = var.prometheus_service_url
      loki_enabled          = var.loki_enabled
      loki_url              = var.loki_service_url
      fetched_notifications = var.fetched_notifications_datasource
      secrets_path          = local.secrets_path
    }))
    dashboard_providers = {
      apiVersion = 1
      providers = [for name, cm in local.dashboard_config_maps : {
        name            = name
        folder          = lookup(local.dashboard_folders, name, name)
        orgId           = 1
        type            = "file"
        disableDeletion = false
        options         = { path = "/var/lib/grafana/dashboards/${name}" }
      }]
    }
    dashboards_config_maps = { for name, cm in local.dashboard_config_maps : name => cm.metadata[0].name }
  }), yamlencode(local.resource_values)]
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
    "prometheus.json"     = data.local_file.prometheus_dashboard.content
    "jvm-micrometer.json" = data.local_file.jvm_micrometer_dashboard.content
  }

  lifecycle {
    precondition {
      condition     = !contains([data.local_file.prometheus_dashboard.filename, data.local_file.jvm_micrometer_dashboard.filename], ".gitkeep")
      error_message = "one or more of the dashboard files are missing."
    }
  }
}

resource "kubernetes_config_map_v1" "grafana_kubernetes_dashboards" {
  metadata {
    name      = "kubernetes-grafana-dashboards"
    namespace = var.target_namespace
    labels = {
      "app"       = local.app
      "component" = local.app
      "release"   = local.app
    }
  }

  data = {
    "kubernetes-views-global.json"      = data.local_file.kubernetes_views_global_dashboard.content
    "kubernetes-views-namespaces.json"  = data.local_file.kubernetes_views_namespaces_dashboard.content
    "kubernetes-views-nodes.json"       = data.local_file.kubernetes_views_nodes_dashboard.content
    "kubernetes-views-pods.json"        = data.local_file.kubernetes_views_pods_dashboard.content
    "kubernetes-system-api-server.json" = data.local_file.kubernetes_system_api_server_dashboard.content
    "kubernetes-system-coredns.json"    = data.local_file.kubernetes_system_coredns_dashboard.content
  }

  lifecycle {
    precondition {
      condition     = !contains([data.local_file.kubernetes_views_global_dashboard.filename, data.local_file.kubernetes_views_namespaces_dashboard.filename, data.local_file.kubernetes_views_nodes_dashboard.filename, data.local_file.kubernetes_views_pods_dashboard.filename, data.local_file.kubernetes_system_api_server_dashboard.filename, data.local_file.kubernetes_system_coredns_dashboard.filename], ".gitkeep")
      error_message = "one or more of the dashboard files are missing."
    }
  }
}

resource "kubernetes_config_map_v1" "grafana_demis_dashboards" {
  metadata {
    name      = "demis-grafana-dashboards"
    namespace = var.target_namespace
    labels = {
      "app"       = local.app
      "component" = local.app
      "release"   = local.app
    }
  }

  data = {
    "audit-log-ext-proc.json" = data.local_file.audit_log_ext_proc_dashboard.content
  }
}
