resource "helm_release" "trivy_operator" {
  name       = "trivy-operator"
  chart      = "trivy-operator"
  repository = var.helm_repository
  version    = var.chart_version
  namespace  = var.namespace
  lint       = true
  atomic     = true
  wait       = true

  set {
    name  = "trivy.slow"
    value = var.use_less_resources
  }

  # See GitHub Issue https://github.com/hashicorp/terraform-provider-helm/issues/316
  set {
    name  = "trivy.additionalVulnerabilityReportFields"
    value = replace(var.additional_report_fields, ",", "\\,")
  }

  set {
    name  = "trivy.ignoreUnfixed"
    value = var.ignore_unfixed
  }

  set {
    name = "trivy.severity"
    # See GitHub Issue https://github.com/hashicorp/terraform-provider-helm/issues/316
    value = replace(var.severity_levels, ",", "\\,")
  }

  set {
    name  = "targetNamespaces"
    value = var.scan_namespaces
  }

  set {
    name  = "compliance.cron"
    value = var.cron_job_schedule
  }

  set {
    name  = "operator.scanJobsConcurrentLimit"
    value = var.scan_jobs_limit
  }

  dynamic "set" {
    for_each = var.private_registry_secret_names
    content {
      name  = "operator.privateRegistryScanSecretsNames.${set.value.namespace}"
      value = set.value.token
    }
  }
}
