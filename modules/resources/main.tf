locals {
  istio_proxy_default_resources = {
    limits   = { memory = "128Mi" }
    requests = { cpu = "10m", memory = "64Mi" }
  }
  # Group all the resource definitions by service and define a YAML Resource Block for the Helm Chart as String
  resource_definitions = {
    for rd in distinct(var.resource_definitions) :
    rd.service => {
      replicas = rd.replicas != null ? rd.replicas : null
      resource_block = rd.resources != null && rd.resources != {} ? yamlencode(
        {
          resources = {
            limits = lookup(rd.resources, "limits", {}) != null ? {
              for k, v in lookup(rd.resources, "limits", {}) :
              k => v if v != null && v != ""
            } : null
            requests = lookup(rd.resources, "requests", {}) != null ? {
              for k, v in lookup(rd.resources, "requests", {}) :
              k => v if v != null && v != ""
            } : null
          }
        }
      ) : null
      istio_proxy_resources = {
        limits   = merge(local.istio_proxy_default_resources.limits, try(rd.istio_proxy_resources.limits, {}))
        requests = merge(local.istio_proxy_default_resources.requests, try(rd.istio_proxy_resources.requests, {}))
      }
    }
  }

  # remove all entries with null values
  service_resource_definitions = {
    for k, v in local.resource_definitions :
    k => v if v != null
  }
}
