output "metadata" {
  description = "Prints the metadata information of the generated Kubernetes Secret for the Pull Credentials."
  value = {
    name        = kubernetes_secret_v1.this.metadata[0].name
    namespace   = kubernetes_secret_v1.this.metadata[0].namespace
    labels      = kubernetes_secret_v1.this.metadata[0].labels
    annotations = kubernetes_secret_v1.this.metadata[0].annotations
  }
}
