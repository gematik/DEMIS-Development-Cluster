output "app_chart_versions" {
  description = "The Versions of deployed Helm Charts"
  value       = tolist(local.available_versions)
}

output "istio_version" {
  description = "The Version of the deployed Helm Chart of the Istio Routing Rules"
  value       = nonsensitive(helm_release.istio != null && length(helm_release.istio) == 1 ? helm_release.istio[0].version : null)
}