locals {
  storage_backend_volumes = var.jaeger_storage_backend == "badger" ? {
    badger = {
      mount_path = "/badger"
      read_only  = false
      empty_dir  = {}
    }
  } : {}
  volumes = merge(local.storage_backend_volumes, {
    config = {
      mount_path = "/data"
      read_only  = true
      config_map = kubernetes_config_map_v1.jaeger_configuration.metadata[0].name
    }
    ui-config = {
      mount_path = "/ui"
      read_only  = true
      config_map = kubernetes_config_map_v1.ui_config.metadata[0].name
    }
  })

}

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

          dynamic "port" {
            for_each = kubernetes_service_v1.tracing.spec[0].port
            content {
              name           = port.value.name
              container_port = port.value.target_port
              protocol       = port.value.protocol
            }
          }

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

          dynamic "volume_mount" {
            for_each = local.volumes
            content {
              name       = volume_mount.key
              mount_path = volume_mount.value.mount_path
              read_only  = volume_mount.value.read_only
            }
          }

          resources {
            requests = {
              "cpu"    = "50m"
              "memory" = "256Mi"
            }
            limits = {
              "cpu"    = "500m"
              "memory" = "1024Mi"
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

        dynamic "volume" {
          for_each = local.volumes
          content {
            name = volume.key

            dynamic "empty_dir" {
              for_each = lookup(volume.value, "empty_dir", null) != null ? [1] : []
              content {}
            }

            dynamic "config_map" {
              for_each = lookup(volume.value, "config_map", null) != null ? [1] : []
              content {
                name = volume.value.config_map
              }
            }
          }
        }
      }
    }
  }
}
