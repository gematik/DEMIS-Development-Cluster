#########################
# Workload Resources
#########################

variable "resource_definitions" {
  description = <<EOT
  Replicas, container resources and Istio proxy resources per workload of the namespace (resources.tfvars).
  Workloads without entry keep the module defaults; resources are merged into the chart defaults.
  Services: the components of the active-versions.yaml, additionally kube-state-metrics and prometheus-node-exporter.
  replicas of prometheus-node-exporter (DaemonSet) and audit-log-purger (CronJob) is ignored; jaeger, prometheus, object-storage-service and
  postgres run with one instance (local storage).
EOT
  type = list(object({
    service  = string
    replicas = number
    resources = optional(object({
      limits   = optional(map(string))
      requests = optional(map(string))
    }))
    istio_proxy_resources = optional(object({
      limits   = optional(map(string))
      requests = optional(map(string))
    }))
  }))
  default = []

  validation {
    condition = alltrue([for rd in var.resource_definitions :
      rd.replicas <= 1 if contains(["jaeger", "prometheus", "object-storage-service", "postgres"], rd.service)
    ])
    error_message = "jaeger, prometheus, object-storage-service and postgres keep their data locally and run with at most one replica."
  }
}
