locals {
  # Detect if a JSON Key is used as password, instead of the provided user_password or access token
  password_value = var.password_type == "json_key" ? base64decode(var.user_password) : var.user_password
  # When using JSON Key as password, the password "auth" field does not exist. This field contains typically the base64 encoded user_name and password
  auth_field = var.password_type == "json_key" ? {} : { "auth" = base64encode("${var.user_name}:${local.password_value}") }
  # Define the basic Auth Block for the Docker Registry
  base_docker_auth = {
    "username" = var.user_name
    "email"    = var.user_email
    "password" = local.password_value
  }
}

# Create Pull Secret from Credentials
resource "kubernetes_secret_v1" "this" {
  metadata {
    name        = var.name
    namespace   = var.namespace
    labels      = var.labels
    annotations = var.annotations
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        # add the "auth" field only if the password is not a JSON Key
        (var.registry) = merge(local.base_docker_auth, local.auth_field)
      }
    })
  }
}

