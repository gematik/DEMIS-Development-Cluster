resource "helm_release" "istio_base" {
  name       = "istio-base"
  chart      = "base"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = var.namespace
  lint       = true
  atomic     = true
  wait       = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  chart      = "istiod"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = var.namespace
  lint       = true
  atomic     = true
  wait       = true

  values = [templatefile("${abspath(path.module)}/istiod-chart-values.tftpl.yml", {
    autoscale_enabled      = var.local_deployment ? "false" : "true",
    autoscale_min          = var.replica_count,
    replica_count          = var.replica_count,
    trace_sampling         = var.trace_sampling,
    opentelemetry_hostname = "otlp-collector.istio-system.svc.cluster.local",
    opentelemetry_port     = "4317"
  })]

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingressgateway" {
  name       = "istio-ingressgateway"
  chart      = "gateway"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = var.namespace
  lint       = true
  atomic     = true
  wait       = true

  depends_on = [helm_release.istiod]

  set {
    name  = "autoscaling.enabled"
    value = var.local_deployment ? "false" : "true"
  }

  # only one External IP for the ingress gateway are supported and for_each loop is used
  # to create a single set block if the external_ip variable is not empty
  dynamic "set" {
    for_each = length(var.external_ip) > 0 ? [var.external_ip] : []
    content {
      name  = "service.loadBalancerIP"
      value = var.external_ip
    }
  }

  dynamic "set" {
    for_each = var.ingress_annotations
    content {
      name  = "service.annotations.${set.value.name}"
      value = set.value.value
    }
  }

  set {
    name  = "autoscaling.minReplicas"
    value = var.local_deployment ? "1" : tostring(var.replica_count)
  }

  set {
    name  = "autoscaling.maxReplicas"
    value = var.local_deployment ? "1" : tostring(var.replica_count)
  }

  set {
    name  = "service.type"
    value = var.local_deployment ? "NodePort" : "LoadBalancer"
  }

  dynamic "set" {
    for_each = var.local_deployment ? toset(var.local_node_ports_istio) : []
    content {
      name  = "service.ports[${index(var.local_node_ports_istio, set.value)}].name"
      value = set.value.name
    }
  }

  dynamic "set" {
    for_each = var.local_deployment ? toset(var.local_node_ports_istio) : []
    content {
      name  = "service.ports[${index(var.local_node_ports_istio, set.value)}].protocol"
      value = set.value.protocol
    }
  }

  dynamic "set" {
    for_each = var.local_deployment ? toset(var.local_node_ports_istio) : []
    content {
      name  = "service.ports[${index(var.local_node_ports_istio, set.value)}].port"
      value = set.value.port
    }
  }

  dynamic "set" {
    for_each = var.local_deployment ? toset(var.local_node_ports_istio) : []
    content {
      name  = "service.ports[${index(var.local_node_ports_istio, set.value)}].targetPort"
      value = set.value.targetPort
    }
  }

  dynamic "set" {
    for_each = var.local_deployment ? toset(var.local_node_ports_istio) : []
    content {
      name  = "service.ports[${index(var.local_node_ports_istio, set.value)}].nodePort"
      value = set.value.nodePort
    }
  }

}

resource "helm_release" "istio_egressgateway" {
  name       = "istio-egressgateway"
  chart      = "gateway"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = var.namespace
  lint       = true
  atomic     = true
  wait       = true

  depends_on = [helm_release.istiod]

  set {
    name  = "autoscaling.enabled"
    value = var.local_deployment ? "false" : "true"
  }

  # Egress gateways do not need an external LoadBalancer IP
  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}

resource "helm_release" "istio_cni" {
  name       = "cni"
  chart      = "cni"
  repository = var.helm_repository
  version    = var.chart_version
  # Installation in kube-system is recommended to ensure the priorityClassName can be used
  namespace = "kube-system"
  lint      = true
  atomic    = true
  wait      = true

  set {
    name  = "global.logAsJson"
    value = "true"
  }

  depends_on = [helm_release.istiod]
}
