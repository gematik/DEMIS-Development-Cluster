resource "kubernetes_deployment_v1" "this" {
  # checkov:skip=CKV_K8S_22: Ignore Use read-only filesystem for containers where possible
  # checkov:skip=CKV_K8S_15: Ignore Image Pull Policy should be Always
  metadata {
    name      = local.app
    namespace = var.target_namespace
    labels = {
      "app"       = local.app
      "component" = local.app
      "release"   = local.app
    }
  }

  spec {
    replicas = 1

    revision_history_limit = 10

    selector {
      match_labels = {
        "app"       = local.app
        "component" = local.app
        "release"   = local.app
      }
    }

    strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          "app"                     = local.app
          "component"               = local.app
          "release"                 = local.app
          "sidecar.istio.io/inject" = "false"
        }
        annotations = {
          "checksum/config"                          = sha256(jsonencode(kubernetes_config_map_v1.grafana_config.data))
          "checksum/dashboards-json-config"          = sha256(jsonencode(kubernetes_config_map_v1.grafana_istio_dashboards.data))
          "checksum/dashboards-services-json-config" = sha256(jsonencode(kubernetes_config_map_v1.grafana_istio_services_dashboards.data))
          "checksum/base-dashboard-provider-config"  = sha256(jsonencode(kubernetes_config_map_v1.grafana_base_dashboards.data))
        }
      }

      spec {
        enable_service_links            = true
        service_account_name            = kubernetes_service_account_v1.this.metadata[0].name
        automount_service_account_token = true
        security_context {
          fs_group        = 472
          run_as_group    = 472
          run_as_non_root = true
          run_as_user     = 472
        }

        container {
          name              = local.app
          image             = "grafana/grafana:${local.version}@${local.digest}"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "service"
            container_port = local.port
            protocol       = "TCP"
          }

          readiness_probe {
            http_get {
              path   = "/api/health"
              scheme = "HTTP"
              port   = local.port
            }
          }

          liveness_probe {
            http_get {
              path   = "/api/health"
              scheme = "HTTP"
              port   = local.port
            }
            initial_delay_seconds = 60
            timeout_seconds       = 30
            failure_threshold     = 10
          }

          env {
            name  = "GF_PATHS_DATA"
            value = "/var/lib/grafana/"
          }

          env {
            name  = "GF_PATHS_LOGS"
            value = "/var/log/grafana/"
          }

          env {
            name  = "GF_PATHS_PLUGINS"
            value = "/var/lib/grafana/plugins"
          }

          env {
            name  = "GF_PATHS_PROVISIONING"
            value = "/etc/grafana/provisioning"
          }

          env {
            name  = "GF_AUTH_ANONYMOUS_ENABLED"
            value = "true"
          }

          env {
            name  = "GF_AUTH_ANONYMOUS_ORG_ROLE"
            value = "Admin"
          }

          env {
            name  = "GF_AUTH_BASIC_ENABLED"
            value = "false"
          }

          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value = "-"
          }

          env {
            name  = "GF_SECURITY_ADMIN_USER"
            value = "-"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/grafana/grafana.ini"
            sub_path   = "grafana.ini"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/grafana/provisioning/datasources/datasources.yaml"
            sub_path   = "datasources.yaml"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/grafana/provisioning/dashboards/dashboardproviders.yaml"
            sub_path   = "dashboardproviders.yaml"
          }

          volume_mount {
            name       = "storage"
            mount_path = "/var/lib/grafana"
          }

          volume_mount {
            name       = "dashboards-istio"
            mount_path = "/var/lib/grafana/dashboards/istio"
          }

          volume_mount {
            name       = "dashboards-istio-services"
            mount_path = "/var/lib/grafana/dashboards/istio-services"
          }

          volume_mount {
            name       = "dashboards-base"
            mount_path = "/var/lib/grafana/dashboards/base"
          }
          resources {
            requests = {
              "cpu"    = "250m"
              "memory" = "256Mi"
            }
            limits = {
              "cpu"    = "500m"
              "memory" = "512Mi"
            }
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["NET_RAW", "ALL"]
            }
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.grafana_config.metadata[0].name
          }
        }

        volume {
          name = "dashboards-istio"
          config_map {
            name = kubernetes_config_map_v1.grafana_istio_dashboards.metadata[0].name
          }
        }

        volume {
          name = "dashboards-istio-services"
          config_map {
            name = kubernetes_config_map_v1.grafana_istio_services_dashboards.metadata[0].name
          }
        }

        volume {
          name = "dashboards-base"
          config_map {
            name = kubernetes_config_map_v1.grafana_base_dashboards.metadata[0].name
          }
        }

        volume {
          name = "storage"
          empty_dir {}
        }
      }
    }
  }
}
