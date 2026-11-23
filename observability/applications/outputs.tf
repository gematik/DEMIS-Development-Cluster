output "url_kiali" {
  description = "Cluster-internal Kiali URL, null if not deployed"
  value       = local.kiali_enabled ? module.kiali[0].kiali_service_url : null
}

output "url_grafana" {
  description = "Grafana URL of Kiali (set from outside or of this namespace), null if none"
  value       = local.grafana_url
}

output "url_jaeger" {
  description = "Cluster-internal Jaeger UI URL, null if not deployed"
  value       = local.jaeger_enabled ? module.jaeger[0].tracing_ui_url : null
}

output "url_prometheus" {
  description = "Prometheus URL of Kiali (set from outside or of this namespace), null if none"
  value       = local.prometheus_url
}

output "url_loki" {
  description = "Cluster-internal Loki URL, null if not deployed"
  value       = local.loki_enabled && local.grafana_enabled ? module.loki[0].loki_service_url : null
}

output "audit_log_purger_version" {
  description = "Chart version of the audit-log-purger, empty if not deployed"
  value       = try(module.audit_log_purger[0].app_chart_versions[0], "")
}

output "audit_log_purger_enabled" {
  description = "Whether the audit-log-purger is enabled"
  value       = local.audit_log_purger_enabled
}
