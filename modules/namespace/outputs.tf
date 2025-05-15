output "name" {
  description = "Prints the name of the Namespace"
  value       = kubernetes_namespace_v1.this.metadata[0].name
}

output "labels" {
  description = "Prints the labels of the Namespace"
  value       = kubernetes_namespace_v1.this.metadata[0].labels == null ? {} : kubernetes_namespace_v1.this.metadata[0].labels
}

output "annotations" {
  description = "Prints the annotations of the Namespace"
  value       = kubernetes_namespace_v1.this.metadata[0].annotations == null ? {} : kubernetes_namespace_v1.this.metadata[0].annotations
}
