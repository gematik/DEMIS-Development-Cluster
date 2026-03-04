output "resource_quota_name" {
  description = "The name of the created ResourceQuota, or null if none was created"
  value       = one(kubernetes_resource_quota_v1.this[*].metadata[0].name)
}
