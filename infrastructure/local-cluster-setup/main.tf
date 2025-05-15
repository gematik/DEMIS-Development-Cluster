locals {
  # Create a map of worker nodes that can be iterated over and used to create workers dynamically
  num_workers = { for i in range(var.kind_worker_nodes) : tostring(i) => i }
}

resource "kind_cluster" "cluster" {
  name            = var.kind_cluster_name
  node_image      = "kindest/node:${var.kind_image_tag}"
  wait_for_ready  = true
  kubeconfig_path = "${abspath(path.root)}/kind-config"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # Expose Port 80
      extra_port_mappings {
        container_port = 30000
        host_port      = 80
        protocol       = "TCP"
      }

      # Expose Port 443
      extra_port_mappings {
        container_port = 30001
        host_port      = 443
        protocol       = "TCP"
      }

      # Expose Port 15021 (Istio)
      extra_port_mappings {
        container_port = 30002
        host_port      = 15021
        protocol       = "TCP"
      }
    }

    dynamic "node" {
      for_each = local.num_workers
      content {
        role = "worker"
      }
    }
  }
}
