locals {
  istio_proxy_default_resources = {
    limits   = { memory = "256Mi" }
    requests = { cpu = "10m", memory = "64Mi" }
  }

  default_resource = {
    replicas              = null
    resource_block        = null
    istio_proxy_resources = local.istio_proxy_default_resources
  }

  normalized_resources = {
    for rd in var.resource_definitions : rd.service =>
    merge(
      try(length(keys(rd.resources.limits)) > 0 ? { limits = { for k, v in rd.resources.limits : k => v if v != null && v != "" } } : {}, {}),
      try(length(keys(rd.resources.requests)) > 0 ? { requests = { for k, v in rd.resources.requests : k => v if v != null && v != "" } } : {}, {})
    )
  }
  # Group all the resource definitions by service and define a YAML Resource Block for the Helm Chart as String
  resource_definitions = {
    for rd in distinct(var.resource_definitions) :
    rd.service => {
      replicas       = rd.replicas,
      resource_block = contains(keys(local.normalized_resources[rd.service]), "limits") || contains(keys(local.normalized_resources[rd.service]), "requests") ? yamlencode({ resources = local.normalized_resources[rd.service] }) : null,
      istio_proxy_resources = {
        limits   = merge(local.istio_proxy_default_resources.limits, try(rd.istio_proxy_resources.limits, {}))
        requests = merge(local.istio_proxy_default_resources.requests, try(rd.istio_proxy_resources.requests, {}))
      }
    }
  }

  # remove all entries with null values

  service_resource_definitions = {
    for service in distinct(compact(concat(var.services, [for s in var.resource_definitions : s.service]))) :
    service => coalesce(lookup(local.resource_definitions, service, null), local.default_resource)
  }
}
