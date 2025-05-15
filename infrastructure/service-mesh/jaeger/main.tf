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
    "config.yml" = templatefile("${path.module}/config.tftpl.yml", {
      health_check_port = local.health_check_port,
      otlp_grpc_port    = local.grpc_otlp_collector_port,
      otlp_http_port    = local.http_otlp_collector_port,
      grpc_query_port   = local.grpc_query_port,
      http_query_port   = local.http_query_port,
      max_traces        = var.jaeger_max_traces
    })
  }
}
