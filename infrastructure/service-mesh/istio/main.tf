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

  set = flatten([[{
    name  = "autoscaling.enabled"
    value = var.local_deployment ? "false" : "true"
    },
    {
      name  = "autoscaling.minReplicas"
      value = var.local_deployment ? "1" : tostring(var.replica_count)
    },
    {
      name  = "autoscaling.maxReplicas"
      value = var.local_deployment ? "1" : tostring(var.replica_count)
    },
    {
      name  = "service.type"
      value = var.local_deployment ? "NodePort" : "LoadBalancer"
    }],
    # only one External IP for the ingress gateway are supported and for_each loop is used
    # to create a single set block if the external_ip variable is not empty
    [for ip in
      (length(var.external_ip) > 0 ? [var.external_ip] : []) :
      {
        name  = "service.loadBalancerIP"
        value = var.external_ip
      }
    ],
    [for annotation in var.ingress_annotations :
      {
        name  = "service.annotations.${annotation.name}"
        value = annotation.value
      }
    ],
    flatten(
      [for istio_node_ports in(var.local_deployment ? var.local_node_ports_istio : []) : [
        {
          name  = "service.ports[${index(var.local_node_ports_istio, istio_node_ports)}].name"
          value = istio_node_ports.name
        },
        {
          name  = "service.ports[${index(var.local_node_ports_istio, istio_node_ports)}].protocol"
          value = istio_node_ports.protocol
        },
        {
          name  = "service.ports[${index(var.local_node_ports_istio, istio_node_ports)}].port"
          value = istio_node_ports.port
        },
        {
          name  = "service.ports[${index(var.local_node_ports_istio, istio_node_ports)}].targetPort"
          value = istio_node_ports.targetPort
        },
        {
          name  = "service.ports[${index(var.local_node_ports_istio, istio_node_ports)}].nodePort"
          value = istio_node_ports.nodePort
        }
        ]
  ])])

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

  set = [{
    name  = "autoscaling.enabled"
    value = var.local_deployment ? "false" : "true"
    },
    # Egress gateways do not need an external LoadBalancer IP
    {
      name  = "service.type"
      value = "ClusterIP"
  }]
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

  set = [{
    name  = "global.logAsJson"
    value = "true"
  }]

  depends_on = [helm_release.istiod]
}
