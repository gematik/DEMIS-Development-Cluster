# demis

Module responsible for configuring and deploying the DEMIS Services in a Kubernetes Cluster.

It performs the following operations:

- creates a Namespace where to deploy the different Kubernetes Objects
- creates Secrets
- creates ConfigMaps for Feature/Ops Flags
- creates PersistenceVolumeClaims
- deploys the Helm Charts for the services

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.36.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_endpoints"></a> [endpoints](#module\_endpoints) | ../modules/endpoints | n/a |
| <a name="module_mesh_namespace"></a> [mesh\_namespace](#module\_mesh\_namespace) | ../modules/namespace | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.authorization_policies_istio](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [helm_release.network_rules_istio](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) | resource |
| [kubernetes_secret.demis_gateway_mutual_tls_credential](https://registry.terraform.io/providers/hashicorp/kubernetes/2.36.0/docs/resources/secret) | resource |
| [kubernetes_secret.demis_gateway_tls_credential](https://registry.terraform.io/providers/hashicorp/kubernetes/2.36.0/docs/resources/secret) | resource |
| [kubernetes_secret.s3_tls_credential](https://registry.terraform.io/providers/hashicorp/kubernetes/2.36.0/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bundid_idp_issuer_subdomain"></a> [bundid\_idp\_issuer\_subdomain](#input\_bundid\_idp\_issuer\_subdomain) | The BundID IDP Issuer URL to be used for the JSON Web Token (JWT) validation | `string` | `""` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The Domain Name to be used for the DEMIS Environment | `string` | n/a | yes |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The Helm Repository where is stored the Helm Chart | `string` | n/a | yes |
| <a name="input_helm_repository_password"></a> [helm\_repository\_password](#input\_helm\_repository\_password) | The Password credential for the Helm Repository | `string` | `""` | no |
| <a name="input_helm_repository_username"></a> [helm\_repository\_username](#input\_helm\_repository\_username) | The Username credential for the Helm Repository | `string` | `""` | no |
| <a name="input_istio_gateway_mutual_tls_ca_certificate"></a> [istio\_gateway\_mutual\_tls\_ca\_certificate](#input\_istio\_gateway\_mutual\_tls\_ca\_certificate) | Base64-encoded, PEM Certificate Authority certificate to be used for configuring the Mutual-TLS Settings for the Istio Gateway for core services. | `string` | `""` | no |
| <a name="input_istio_gateway_mutual_tls_certificate"></a> [istio\_gateway\_mutual\_tls\_certificate](#input\_istio\_gateway\_mutual\_tls\_certificate) | Base64-encoded, PEM certificate to be used for configuring the Mutual-TLS Settings for the Istio Gateway for core services. | `string` | `""` | no |
| <a name="input_istio_gateway_mutual_tls_private_key"></a> [istio\_gateway\_mutual\_tls\_private\_key](#input\_istio\_gateway\_mutual\_tls\_private\_key) | Base64-encoded, PEM private key associated to the certificate for the Mutual-TLS Settings. | `string` | `""` | no |
| <a name="input_istio_gateway_tls_certificate"></a> [istio\_gateway\_tls\_certificate](#input\_istio\_gateway\_tls\_certificate) | Base64-encoded, PEM certificate to be used for configuring the TLS Settings for the Istio Gateway for Portal, Keycloak and MinIO subdomains. | `string` | n/a | yes |
| <a name="input_istio_gateway_tls_private_key"></a> [istio\_gateway\_tls\_private\_key](#input\_istio\_gateway\_tls\_private\_key) | Base64-encoded, PEM private key associated to the certificate for the TLS Settings. | `string` | n/a | yes |
| <a name="input_kms_encryption_key"></a> [kms\_encryption\_key](#input\_kms\_encryption\_key) | The GCP KMS encryption key for OpenTofu state encryption | `string` | `""` | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig file for the cluster | `string` | `""` | no |
| <a name="input_override_stage_name"></a> [override\_stage\_name](#input\_override\_stage\_name) | Override the automatically detected stage name (optional) | `string` | `""` | no |
| <a name="input_portal_test_token_certificate"></a> [portal\_test\_token\_certificate](#input\_portal\_test\_token\_certificate) | Base64-encoded, PEM certificate to be used for injecting the test token into the Portal. | `string` | `""` | no |
| <a name="input_s3_hostname"></a> [s3\_hostname](#input\_s3\_hostname) | The Hostname of the S3 Storage Server | `string` | `""` | no |
| <a name="input_s3_port"></a> [s3\_port](#input\_s3\_port) | The Port of the Remote S3 Storage | `number` | `9000` | no |
| <a name="input_s3_tls_credential"></a> [s3\_tls\_credential](#input\_s3\_tls\_credential) | Base64-encoded, PEM certificate to be used for configuring the TLS Settings for the S3 Storage Server. | `string` | `""` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | The Namespace to use for the deployment of mesh components | `string` | `"mesh"` | no |
| <a name="input_ti_idp_subdomain"></a> [ti\_idp\_subdomain](#input\_ti\_idp\_subdomain) | The URL to access the DEMIS Notification Portal over the Telematikinfrastruktur (TI) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_istio_gateway_name"></a> [istio\_gateway\_name](#output\_istio\_gateway\_name) | The name of the Istio Gateway for the DEMIS Cluster |
| <a name="output_kms_encryption_key_used"></a> [kms\_encryption\_key\_used](#output\_kms\_encryption\_key\_used) | The flag to indicate if the KMS encryption key is used |
| <a name="output_stage_name"></a> [stage\_name](#output\_stage\_name) | Current stage |
<!-- END_TF_DOCS -->