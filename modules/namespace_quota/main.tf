resource "kubernetes_resource_quota_v1" "this" {
  count = var.resource_quota != null ? 1 : 0

  metadata {
    name      = "${var.namespace}-quota"
    namespace = var.namespace
  }

  spec {
    hard = { for key, value in local.quota_hard : key => value if value != null }
  }
}

locals {
  quota_hard = {
    "limits.cpu"      = try(var.resource_quota.limits_cpu, null)
    "limits.memory"   = try(var.resource_quota.limits_memory, null)
    "requests.cpu"    = try(var.resource_quota.requests_cpu, null)
    "requests.memory" = try(var.resource_quota.requests_memory, null)
  }
}
