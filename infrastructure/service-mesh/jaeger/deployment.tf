resource "kubernetes_deployment_v1" "this" {
  # checkov:skip=CKV_K8S_15: Ignore Image Pull Policy should be Always
  # checkov:skip=CKV_K8S_22: Ignore Use read-only filesystem for containers where possible
  metadata {
    name      = local.app
    namespace = var.target_namespace
    labels = {
      "app"                         = local.app
      "app.kubernetes.io/component" = local.component
    }
  }

  spec {
    replicas = 1

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        "app"                         = local.app
        "app.kubernetes.io/component" = local.component
      }
    }

    template {
      metadata {
        labels = {
          "app"                         = local.app
          "app.kubernetes.io/component" = local.component
          "sidecar.istio.io/inject"     = "false"
        }
      }

      spec {
        container {
          name              = local.app
          image             = "docker.io/jaegertracing/jaeger:${local.version}@${local.digest}"
          image_pull_policy = "IfNotPresent"
          args              = ["--config", "/data/config.yml"]

          readiness_probe {
            http_get {
              path   = "/status"
              scheme = "HTTP"
              port   = local.health_check_port
            }
            initial_delay_seconds = 1
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
            success_threshold     = 1
          }

          liveness_probe {
            http_get {
              path   = "/status"
              scheme = "HTTP"
              port   = local.health_check_port
            }
            initial_delay_seconds = 5
            period_seconds        = 15
            timeout_seconds       = 5
            failure_threshold     = 3
            success_threshold     = 1
          }

          volume_mount {
            name       = "badger"
            mount_path = "/badger"
          }

          volume_mount {
            name       = "config"
            mount_path = "/data"
            read_only  = true
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

        dns_policy = "ClusterFirst"

        security_context {
          fs_group        = 65534
          run_as_group    = 65534
          run_as_non_root = true
          run_as_user     = 65534
        }

        volume {
          name = "badger"
          empty_dir {}
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.jaeger_configuration.metadata[0].name
          }
        }
      }
    }
  }
}
