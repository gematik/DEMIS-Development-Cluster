# Create the required Service Account and the its Roles

resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = var.service_account_name
    namespace = var.target_namespace
  }
}

resource "kubernetes_secret_v1" "this" {
  type = "kubernetes.io/service-account-token"

  metadata {
    name      = "${kubernetes_service_account_v1.this.metadata[0].name}-token"
    namespace = var.target_namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.this.metadata[0].name
    }
  }
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  metadata {
    name = "${kubernetes_cluster_role_v1.this.metadata[0].name}-binding"
  }
  subject {
    kind      = "ServiceAccount"
    namespace = var.target_namespace
    name      = kubernetes_service_account_v1.this.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.this.metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "this" {
  metadata {
    name = var.cluster_role_name
  }

  rule {
    api_groups = [
      "",
      "apps",
      "autoscaling",
      "batch",
      "extensions",
      "policy",
      "rbac.authorization.k8s.io",
      "networking.istio.io",
      "authentication.istio.io",
      "rbac.istio.io",
      "config.istio.io",
      "security.istio.io"
    ]

    resources = [
      "pods",
      "pods/attach",
      "pods/exec",
      "componentstatuses",
      "configmaps",
      "cronjobs",
      "daemonsets",
      "deployments",
      "deployments/scale",
      "statefulsets/scale",
      "events",
      "endpoints",
      "horizontalpodautoscalers",
      "ingress",
      "jobs",
      "limitranges",
      "namespaces",
      "nodes",
      "pods",
      "persistentvolumes",
      "persistentvolumeclaims",
      "resourcequotas",
      "replicasets",
      "replicationcontrollers",
      "serviceaccounts",
      "services",
      "secrets",
      "statefulsets",
      "gateways",
      "wasmplugins",
      "istiooperators",
      "destinationrules",
      "envoyfilters",
      "proxyconfigs",
      "serviceentries",
      "sidecars",
      "virtualservices",
      "workloadentries",
      "workloadgroups",
      "authorizationpolicies",
      "peerauthentications",
      "requestauthentications",
      "telemetries"
    ]

    verbs = [
      "get", "list", "watch", "create", "update", "patch", "delete"
    ]
  }
}
