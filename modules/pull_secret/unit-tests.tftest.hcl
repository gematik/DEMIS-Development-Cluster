provider "kubernetes" {
  config_path = "${path.module}/.test_kubeconfig"
}

# Test common Plain Credentials (e.g. for Docker Hub)
run "plain_credentials_test" {
  command = plan

  variables {
    namespace     = "demis"
    name          = "test-credentials"
    registry      = "docker.io"
    user_name     = "myuser"
    user_email    = "myuser@example.com"
    user_password = "test-password"
    password_type = "plain"
  }

  # assert that output is correct
  assert {
    condition     = output.metadata.name == var.name
    error_message = "The Name of the Kubernetes Secret is not correct."
  }

  # assert that output is correct
  assert {
    condition     = output.metadata.namespace == var.namespace
    error_message = "The Namespace of the Kubernetes Secret is not correct."
  }

  # assert that the internal content of the secret is correct
  assert {
    condition = kubernetes_secret_v1.this.data[".dockerconfigjson"] == jsonencode({
      auths = {
        "docker.io" = {
          "username" = var.user_name,
          "email"    = var.user_email,
          "password" = var.user_password,
          "auth"     = base64encode("${var.user_name}:${var.user_password}")
        }
      }
    })
    error_message = "Kubernetes Secret Data is not correct, got: ${nonsensitive(kubernetes_secret_v1.this.data[".dockerconfigjson"])}"
  }
}

# Test GCloud Token Credentials
run "gcloud_token_credentials_test" {
  command = plan

  variables {
    namespace     = "demis-gcloud"
    name          = "test-gcloud-credentials"
    registry      = "eu.gcr.io"
    user_name     = "test-user"
    user_email    = "test-user@google.com"
    user_password = "random-access-token-from-gcloud-cli"
    password_type = "token"
  }

  # assert that output is correct
  assert {
    condition     = output.metadata.name == var.name
    error_message = "The Name of the Kubernetes Secret is not correct."
  }

  # assert that output is correct
  assert {
    condition     = output.metadata.namespace == var.namespace
    error_message = "The Namespace of the Kubernetes Secret is not correct."
  }

  # assert that the content of the secret is correct
  assert {
    condition = kubernetes_secret_v1.this.data[".dockerconfigjson"] == jsonencode({
      auths = {
        "eu.gcr.io" = {
          "username" = var.user_name,
          "email"    = var.user_email,
          "password" = var.user_password,
          "auth"     = base64encode("${var.user_name}:${var.user_password}")
        }
      }
    })
    error_message = "Kubernetes Secret Data with Token for Google Artifact Registry is not correct, got: ${nonsensitive(kubernetes_secret_v1.this.data[".dockerconfigjson"])}"
  }
}

# Test Google Cloud JSON Keys
run "gcloud_jsonkey_test" {
  command = plan

  variables {
    namespace     = "demis-jsonkey"
    name          = "test-json-key"
    registry      = "eu.gcr.io"
    user_name     = "_json_key"
    user_email    = "test-user@gmail.com"
    user_password = "eyJzb21lLXJhbmRvbS1kYXRhIjogInRlc3QtcGFzc3dvcmQifQ=="
    password_type = "json_key"
  }

  # assert that output is correct
  assert {
    condition     = output.metadata.name == var.name
    error_message = "The Name of the Kubernetes Secret is not correct."
  }

  # assert that output is correct
  assert {
    condition     = output.metadata.namespace == var.namespace
    error_message = "The Namespace of the Kubernetes Secret is not correct."
  }

  # assert that the content of the secret is correct
  assert {
    condition = kubernetes_secret_v1.this.data[".dockerconfigjson"] == jsonencode({
      auths = {
        "eu.gcr.io" = {
          "username" = var.user_name,
          "email"    = var.user_email,
          "password" = base64decode(var.user_password)
        }
      }
    })
    error_message = "Kubernetes Secret Data from JSON Key for Google Artifact Registry is not correct, got: ${nonsensitive(kubernetes_secret_v1.this.data[".dockerconfigjson"])}"
  }
}
