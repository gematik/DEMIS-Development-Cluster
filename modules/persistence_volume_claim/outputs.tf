output "metadata" {
  description = "Prints the Metadata Information of the created Kubernetes Persistence Volume Claim"
  value = {
    name      = kubernetes_persistent_volume_claim_v1.this.metadata[0].name
    namespace = kubernetes_persistent_volume_claim_v1.this.metadata[0].namespace
  }
}
