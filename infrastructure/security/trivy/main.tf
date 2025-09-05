resource "helm_release" "trivy_operator" {
  name       = "trivy-operator"
  chart      = "trivy-operator"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = var.namespace
  lint       = true
  atomic     = true
  wait       = true

  set = flatten([[{
    name  = "trivy.slow"
    value = var.use_less_resources
    },
    # See GitHub Issue https://github.com/hashicorp/terraform-provider-helm/issues/316
    {
      name  = "trivy.additionalVulnerabilityReportFields"
      value = replace(var.additional_report_fields, ",", "\\,")
    },
    {
      name  = "trivy.ignoreUnfixed"
      value = var.ignore_unfixed
    },
    {
      name = "trivy.severity"
      # See GitHub Issue https://github.com/hashicorp/terraform-provider-helm/issues/316
      value = replace(var.severity_levels, ",", "\\,")
    },
    {
      name  = "targetNamespaces"
      value = var.scan_namespaces
    },
    {
      name  = "compliance.cron"
      value = var.cron_job_schedule
    },
    {
      name  = "operator.scanJobsConcurrentLimit"
      value = var.scan_jobs_limit
    }],
    [for secret in var.private_registry_secret_names :
      {
        name  = "operator.privateRegistryScanSecretsNames.${secret.namespace}"
        value = secret.token
      }
  ]])
}
