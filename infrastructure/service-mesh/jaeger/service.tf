resource "kubernetes_service_v1" "tracing" {
  metadata {
    name      = "tracing"
    namespace = var.target_namespace
    labels = {
      "app" = local.app
    }
  }
  spec {
    type = "ClusterIP"

    selector = {
      "app" = local.app
    }

    port {
      name        = "http-query"
      protocol    = "TCP"
      port        = 80
      target_port = local.http_query_port
    }

    port {
      name        = "grpc-query"
      protocol    = "TCP"
      port        = local.grpc_query_port
      target_port = local.grpc_query_port
    }
  }
}

# Jaeger implements the OpenTelemetry API. To support swapping out the tracing backend, this Service is created.
resource "kubernetes_service_v1" "otlp_collector" {
  metadata {
    name      = "otlp-collector"
    namespace = var.target_namespace
    labels = {
      "app" = local.app
    }
  }
  spec {
    type = "ClusterIP"

    selector = {
      "app" = local.app
    }

    port {
      name        = "http-otel"
      protocol    = "TCP"
      port        = local.http_otlp_collector_port
      target_port = local.http_otlp_collector_port
    }

    port {
      name        = "grpc-otel"
      protocol    = "TCP"
      port        = local.grpc_otlp_collector_port
      target_port = local.grpc_otlp_collector_port
    }
  }
}
