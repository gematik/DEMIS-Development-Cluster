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

# Patch the kube-apiserver manifest inside the KIND control-plane container
# to enable the ResourceQuota admission plugin after cluster creation.
# After patching, the kubelet detects the manifest change and restarts the
# kube-apiserver static pod automatically. We therefore wait until the API
# server is reachable again before signalling completion to dependent resources.
resource "null_resource" "enable_resource_quota" {
  depends_on = [kind_cluster.cluster]

  provisioner "local-exec" {
    # Step 1: Patch the kube-apiserver manifest (no-op if already patched).
    command = <<-EOT
      docker exec ${var.kind_cluster_name}-control-plane \
        sh -c "grep -q 'ResourceQuota' /etc/kubernetes/manifests/kube-apiserver.yaml || \
        sed -i 's/--enable-admission-plugins=\([^,]*\)/--enable-admission-plugins=\1,ResourceQuota/' \
        /etc/kubernetes/manifests/kube-apiserver.yaml"
    EOT
  }

  provisioner "local-exec" {
    # Step 2: Wait for the kube-apiserver to become ready again after the
    # manifest patch triggers a static-pod restart by the kubelet.
    # Polls every 5 seconds for up to 120 seconds (24 attempts).
    command = <<-EOT
      echo "Waiting for kube-apiserver to restart after ResourceQuota patch..."
      KUBECONFIG="${abspath(path.root)}/kind-config"
      attempts=0
      until kubectl --kubeconfig="$KUBECONFIG" get --raw="/readyz" >/dev/null 2>&1; do
        attempts=$((attempts + 1))
        if [ $attempts -ge 24 ]; then
          echo "ERROR: kube-apiserver did not become ready within 120 seconds."
          exit 1
        fi
        echo "  API server not ready yet (attempt $attempts/24), retrying in 5s..."
        sleep 5
      done
      echo "kube-apiserver is ready."
    EOT
  }
}
