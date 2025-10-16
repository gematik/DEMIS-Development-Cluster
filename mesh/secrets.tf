#####################
# Gateway Credentials
#####################

resource "kubernetes_secret" "demis_gateway_tls_credential" {
  metadata {
    name      = "demis-istio-tls"
    namespace = "istio-system"
  }

  immutable = true

  data = {
    "tls.crt" = base64decode(var.istio_gateway_tls_certificate)
    "tls.key" = base64decode(var.istio_gateway_tls_private_key)
  }
}

# Activated the Mutual TLS Secret only in the local environment
resource "kubernetes_secret" "demis_gateway_mutual_tls_credential" {
  count = local.is_local_mode ? 1 : 0

  metadata {
    name      = "demis-istio-mutual-tls"
    namespace = "istio-system"
  }

  immutable = true

  data = {
    "cacert"  = base64decode(var.istio_gateway_mutual_tls_ca_certificate)
    "tls.crt" = base64decode(var.istio_gateway_mutual_tls_certificate)
    "tls.key" = base64decode(var.istio_gateway_mutual_tls_private_key)
  }
}

#############################
# S3 TLS Secret
#############################
resource "kubernetes_secret" "s3_tls_credential" {
  count = local.is_local_mode ? 0 : 1
  metadata {
    name      = "s3-tls-certificate"
    namespace = "istio-system"
  }
  immutable = true
  data = {
    "cacert" = base64decode(var.s3_tls_credential)
  }
}
