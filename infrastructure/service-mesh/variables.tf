variable "local_deployment" {
  description = "Defines if the components (Grafana, Prometheus) have to be installed locally."
  type        = bool
  default     = false
}

variable "local_node_ports_istio" {
  description = "Defines the node ports to use with the local cluster (kind)"
  type = list(object({
    port       = number
    targetPort = number
    name       = string
    protocol   = string
    nodePort   = string
  }))
  default = [{
    name       = "status-port"
    protocol   = "TCP"
    port       = 15021
    targetPort = 15021
    nodePort   = 30002
    },
    {
      name       = "http2"
      protocol   = "TCP"
      port       = 80
      targetPort = 80
      nodePort   = 30000
    },
    {
      name       = "https"
      protocol   = "TCP"
      port       = 443
      targetPort = 443
      nodePort   = 30001
  }]
}

variable "namespace" {
  description = "Namespace where to install the services"
  type        = string
  default     = "istio-system"
}

variable "istio_version" {
  type        = string
  default     = "1.23.0"
  description = "The version of the Istio Helm Chart to be installed."
}

variable "istio_replica_count" {
  description = "The number of replicas that have to be configured for the Istio services"
  type        = number
  default     = 3
}

variable "kiali_enabled" {
  description = "Defines if Kiali has to be deployed"
  type        = bool
  default     = true
}

variable "kiali_version" {
  description = "The version of the Kiali Helm Chart to be installed"
  type        = string
  default     = "2.5.0"
}

variable "prometheus_enabled" {
  description = "Defines if Prometheus has to be deployed"
  type        = bool
  default     = false
}

variable "prometheus_version" {
  description = "The version of the Prometheus Service to be installed"
  type        = string
  default     = "27.3.0"
}

variable "jaeger_enabled" {
  description = "Defines if Jaeger has to be deployed"
  type        = bool
  default     = true
}

variable "jaeger_version" {
  description = "The version of the Jaeger Service to be installed"
  type        = string
  default     = "1.66.0"
}

variable "jaeger_digest" {
  description = "The digest of the Jaeger Service to be used"
  type        = string
  default     = "sha256:9864182b4e01350fcc64631bdba5f4085f87daae9d477a04c25d9cb362e787a9"
}

variable "grafana_enabled" {
  description = "Defines if Grafana has to be deployed"
  type        = bool
  default     = false
}

variable "grafana_version" {
  description = "The version of the Grafana Service to be installed"
  type        = string
  default     = "11.5.1"
}

variable "grafana_digest" {
  description = "The digest of the Grafana Service to be used"
  type        = string
  default     = "sha256:5781759b3d27734d4d548fcbaf60b1180dbf4290e708f01f292faa6ae764c5e6"
}

variable "trace_sampling" {
  description = "The sampling rate option can be used to control what percentage of requests get reported to your tracing system. (https://istio.io/latest/docs/tasks/observability/distributed-tracing/mesh-and-proxy-config/#customizing-trace-sampling)"
  type        = string
  default     = "1.0"
}

variable "external_ip" {
  description = "The external IP of the ingress gateway, only single IP is supported"
  type        = string
  default     = ""
}

variable "ingress_annotations" {
  description = "The annotations to be used for the ingress gateway"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "prometheus_service_url" {
  description = "The Cluster-internal URL of the Prometheus Instance to be used"
  type        = string
  default     = "http://prometheus:9090"
}

variable "tracing_service_url" {
  description = "The Cluster-internal URL of the Tracing Instance to be used"
  type        = string
  default     = "http://tracing:16685/jaeger"
}

variable "grafana_service_url" {
  description = "The Cluster-internal URL of the Grafana Instance to be used"
  type        = string
  default     = "http://grafana:3000"
}

variable "grafana_public_url" {
  description = "The Public URL for Grafana (Used in Kiali as link, if activated)"
  type        = string
  default     = "http://localhost:3000"
}
