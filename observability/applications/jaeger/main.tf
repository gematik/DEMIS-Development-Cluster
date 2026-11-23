# Based on Istio Addon: https://github.com/istio/istio/blob/1.25.0/samples/addons/jaeger.yaml
# See Jaeger Documentation: https://www.jaegertracing.io/docs/next-release-v2/migration/
locals {
  app                      = "jaeger"
  component                = "jaeger-collector"
  version                  = var.jaeger_version
  digest                   = var.jaeger_digest
  grpc_otlp_collector_port = 4317
  http_otlp_collector_port = 4318
  grpc_query_port          = 16685
  http_query_port          = 16686
  health_check_port        = 13133
  # Service for the in-mesh OTLP exports (TCP, see service.tf)
  otlp_internal_service = "otlp-collector-internal"

  # Resources and sidecar annotations (resources.tfvars), merged into the defaults; one replica (in-memory/local storage)
  resource_definition = try(var.resource_definitions.jaeger, null)
  resource_block      = try(yamldecode(local.resource_definition.resource_block).resources, {})
  resources = {
    requests = merge({ cpu = "50m", memory = "256Mi" }, try(local.resource_block.requests, {}))
    limits   = merge({ cpu = "500m", memory = "1024Mi" }, try(local.resource_block.limits, {}))
  }
  istio_proxy_annotations = try({
    "sidecar.istio.io/proxyCPU"         = local.resource_definition.istio_proxy_resources.requests.cpu
    "sidecar.istio.io/proxyMemory"      = local.resource_definition.istio_proxy_resources.requests.memory
    "sidecar.istio.io/proxyMemoryLimit" = local.resource_definition.istio_proxy_resources.limits.memory
  }, {})
}

resource "kubernetes_config_map_v1" "jaeger_configuration" {
  metadata {
    name      = "jaeger-configuration"
    namespace = var.target_namespace
    labels = {
      "app"       = local.app
      "component" = local.app
      "release"   = local.app
    }
  }

  data = {
    "config.yml" = templatefile("${path.module}/config/config.tftpl.yml", {
      health_check_port      = local.health_check_port,
      otlp_grpc_port         = local.grpc_otlp_collector_port,
      otlp_http_port         = local.http_otlp_collector_port,
      grpc_query_port        = local.grpc_query_port,
      http_query_port        = local.http_query_port,
      max_traces             = var.jaeger_max_traces
      ttl_spans              = var.jaeger_ttl_spans
      jaeger_storage_backend = var.jaeger_storage_backend
      namespace              = var.target_namespace
    })
  }
}

resource "kubernetes_config_map_v1" "ui_config" {
  metadata {
    name      = "jaeger-ui-config"
    namespace = var.target_namespace
    labels = {
      "app"       = local.app
      "component" = local.app
      "release"   = local.app
    }
  }

  data = {
    "jaeger-ui.json" = <<EOT
{
  "themes": {
    "enabled": true
  }
}
EOT
  }
}
