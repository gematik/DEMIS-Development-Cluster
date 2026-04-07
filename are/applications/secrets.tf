locals {
  redis_cus_reader_password_data = {
    REDIS_USER     = var.redis_cus_reader_user
    REDIS_PASSWORD = var.redis_cus_reader_password
  }
}

resource "kubernetes_secret_v1" "redis_cus_reader_credentials" {
  metadata {
    name      = "redis-cus-reader-password"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode(local.redis_cus_reader_password_data)), 0, 61)
    }
  }

  immutable = true

  data = local.redis_cus_reader_password_data
}