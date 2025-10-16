output "chart_version" {
  description = "Trivy Operator Helm Chart Version"
  value       = var.chart_version
}

output "helm_repository" {
  description = "Trivy Operator Helm Repository"
  value       = var.helm_repository
}

output "cron_job_schedule" {
  description = "Trivy Operator Cron Job Schedule"
  value       = var.cron_job_schedule
}