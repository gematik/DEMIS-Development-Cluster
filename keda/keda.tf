locals {
  # Version information from active-versions.yaml, maintained by the update pipelines (copyVersions.sh).
  # KEDA runs as a single cluster-wide operator, so only "main" is supported (no canary).
  keda_deployment = try(local.deployment_information["keda"], {})
  # "chart-name" may point to a local Chart directory for local tests (takes precedence over the repository)
  chart_name    = coalesce(try(local.keda_deployment.chart-name, null), "keda")
  chart_version = try(local.keda_deployment.main.version, null)
  # Chart and images are built and released together, so they share the same version.
  # "image-tag" allows to override it, like for the other DEMIS services.
  image_tag = try(coalesce(try(local.keda_deployment.image-tag, null), local.chart_version), null)

  # The ResourceQuota admission plugin may restrict built-in system PriorityClasses to
  # kube-system (e.g. on GKE). Pods outside of it need a ResourceQuota covering that scope.
  system_priority_class = startswith(var.keda_priority_class_name, "system-")

  # Helm values, analogous to the "applications" of the other modules:
  # the template of the stage replaces the default template of this module,
  # the optional "app-values.yaml" of the stage is applied on top of it.
  keda_values_stage_path = "${local.chart_source_path}/keda"
  keda_values_template   = fileexists("${local.keda_values_stage_path}/app-values.tftpl.yaml") ? "${local.keda_values_stage_path}/app-values.tftpl.yaml" : "${path.module}/applications/keda/app-values.tftpl.yaml"
  keda_values_override   = fileexists("${local.keda_values_stage_path}/app-values.yaml") ? file("${local.keda_values_stage_path}/app-values.yaml") : ""
}

resource "kubernetes_resource_quota_v1" "priority_class" {
  count = local.system_priority_class ? 1 : 0

  metadata {
    name      = "keda-priority-class"
    namespace = module.keda_namespace.name
    labels    = local.labels
  }

  spec {
    # Generous upper bound: KEDA runs three Deployments, plus surge Pods during upgrades
    hard = {
      pods = "20"
    }
    scope_selector {
      match_expression {
        scope_name = "PriorityClass"
        operator   = "In"
        values     = [var.keda_priority_class_name]
      }
    }
  }
}

# Configure KEDA
resource "helm_release" "keda" {
  name                = "keda"
  chart               = local.chart_name
  repository          = local.chart_repository
  repository_username = local.chart_repository_username
  repository_password = local.chart_repository_password
  version             = local.chart_version
  namespace           = module.keda_namespace.name
  lint                = true
  atomic              = true
  wait                = true

  values = compact([
    templatefile(local.keda_values_template, {
      repository          = var.docker_registry
      image_tag           = local.image_tag != null ? local.image_tag : ""
      image_pull_secrets  = local.pull_secrets_credentials
      priority_class_name = var.keda_priority_class_name
    }),
    local.keda_values_override
  ])

  depends_on = [kubernetes_resource_quota_v1.priority_class, module.pull_secrets]

  lifecycle {
    precondition {
      condition     = local.chart_version != null
      error_message = "No KEDA version is defined. Please define 'keda.main.version' in ${local.active_versions_source_path}."
    }
  }
}
