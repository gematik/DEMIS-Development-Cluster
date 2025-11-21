#####################
# Secrets
#####################

resource "kubernetes_secret" "rabbit_mq_credentials" {
  metadata {
    name      = "rabbit-mq-credentials"
    namespace = var.target_namespace
    annotations = {
      checksum = substr(sha256(jsonencode({
        RABBITMQ_USERNAME = var.rabbitmq_username
        RABBITMQ_PASSWORD = var.rabbitmq_password
      })), 0, 61)
    }
  }

  immutable = true

  data = {
    RABBITMQ_USERNAME      = var.rabbitmq_username
    RABBITMQ_PASSWORD      = var.rabbitmq_password
    RABBITMQ_ERLANG_COOKIE = var.rabbitmq_erlang_cookie
  }
}
