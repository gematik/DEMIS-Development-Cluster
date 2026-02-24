#####################
# Gateway Credentials
#####################
locals {
  istio_gateway_tls_data = {
    "tls.crt" = base64decode(var.istio_gateway_tls_certificate)
    "tls.key" = base64decode(var.istio_gateway_tls_private_key)
  }

  demis_gateway_mutual_tls_data = {
    "cacert"  = base64decode(var.istio_gateway_mutual_tls_ca_certificate)
    "tls.crt" = base64decode(var.istio_gateway_mutual_tls_certificate)
    "tls.key" = base64decode(var.istio_gateway_mutual_tls_private_key)
  }

  s3_tls_data = {
    "cacert" = base64decode(var.s3_tls_credential)
  }
}

resource "kubernetes_secret_v1" "demis_gateway_tls_credential" {
  metadata {
    name      = "demis-istio-tls"
    namespace = "istio-system"
    annotations = {
      checksum = substr(sha256(jsonencode(local.istio_gateway_tls_data)), 0, 62)
    }
  }

  immutable = true

  data = local.istio_gateway_tls_data
}

# Activated the Mutual TLS Secret only in the local environment
resource "kubernetes_secret_v1" "demis_gateway_mutual_tls_credential" {
  count = local.is_local_mode ? 1 : 0

  metadata {
    name      = "demis-istio-mutual-tls"
    namespace = "istio-system"
    annotations = {
      checksum = substr(sha256(jsonencode(local.demis_gateway_mutual_tls_data)), 0, 62)
    }
  }

  immutable = true

  data = local.demis_gateway_mutual_tls_data
}

#############################
# S3 TLS Secret
#############################
resource "kubernetes_secret_v1" "s3_tls_credential" {
  count = local.is_local_mode ? 0 : 1
  metadata {
    name      = "s3-tls-certificate"
    namespace = "istio-system"
    annotations = {
      checksum = substr(sha256(jsonencode(local.s3_tls_data)), 0, 62)
    }
  }

  immutable = true

  data = local.s3_tls_data
}
