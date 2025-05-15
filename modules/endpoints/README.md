# endpoints

Module responsible for creating endpoints hostnames, starting from the given domain name.

## Usage

In your Project, create a new `module` Block and pass the desired information:

```hcl
module "endpoints" {
    source = "/path/to/this/module"

    domain_name = "ingress.local"
}
```

## Tests

The module contains unit tests that can be executed with the following command: 

```sh
tofu test
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.35.0, < 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_issuer_subdomain"></a> [auth\_issuer\_subdomain](#input\_auth\_issuer\_subdomain) | The Issuer URL to be used for the JSON Web Token (JWT) validation | `string` | `"auth"` | no |
| <a name="input_bundid_idp_issuer_subdomain"></a> [bundid\_idp\_issuer\_subdomain](#input\_bundid\_idp\_issuer\_subdomain) | The BundID IDP Issuer URL to be used for the JSON Web Token (JWT) validation | `string` | `""` | no |
| <a name="input_check_istio_gateway_exists"></a> [check\_istio\_gateway\_exists](#input\_check\_istio\_gateway\_exists) | Flag to check if the Istio Gateway Object exists | `bool` | `true` | no |
| <a name="input_core_subdomain"></a> [core\_subdomain](#input\_core\_subdomain) | The URL to access the DEMIS Core API | `string` | `""` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The Domain Name to be used for the DEMIS Environment | `string` | n/a | yes |
| <a name="input_istio_gateway_name"></a> [istio\_gateway\_name](#input\_istio\_gateway\_name) | The name of the Istio Gateway Object for accessing the DEMIS Cluster | `string` | `"demis-core-gateway"` | no |
| <a name="input_istio_gateway_namespace"></a> [istio\_gateway\_namespace](#input\_istio\_gateway\_namespace) | The Namespace where the Istio Gateway Object is configured | `string` | `"mesh"` | no |
| <a name="input_keycloak_internal_hostname"></a> [keycloak\_internal\_hostname](#input\_keycloak\_internal\_hostname) | The internal hostname of the Keycloak service | `string` | `"keycloak.idm.svc.cluster.local"` | no |
| <a name="input_meldung_subdomain"></a> [meldung\_subdomain](#input\_meldung\_subdomain) | The URL for accessing the DEMIS Notification Portal over Internet | `string` | `"meldung"` | no |
| <a name="input_portal_subdomain"></a> [portal\_subdomain](#input\_portal\_subdomain) | The URL for accessing the DEMIS Notification Portal over thr Telematikinfrastruktur (TI) | `string` | `"portal"` | no |
| <a name="input_storage_subdomain"></a> [storage\_subdomain](#input\_storage\_subdomain) | The URL to access the S3 compatible storage (minio) | `string` | `"storage"` | no |
| <a name="input_ti_idp_subdomain"></a> [ti\_idp\_subdomain](#input\_ti\_idp\_subdomain) | The URL to access the DEMIS Notification Portal over the Telematikinfrastruktur (TI) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth_hostname"></a> [auth\_hostname](#output\_auth\_hostname) | The URL for accessing the Keycloak Authentication Services |
| <a name="output_bundid_idp_hostname"></a> [bundid\_idp\_hostname](#output\_bundid\_idp\_hostname) | The URL for for performing the login with BundID |
| <a name="output_core_hostname"></a> [core\_hostname](#output\_core\_hostname) | The URL for accessing the DEMIS Core Services |
| <a name="output_frontend_hostnames"></a> [frontend\_hostnames](#output\_frontend\_hostnames) | The Hostnames for the DEMIS Portal Istio Virtual Services |
| <a name="output_istio_gateway_fullname"></a> [istio\_gateway\_fullname](#output\_istio\_gateway\_fullname) | The full name of the Istio Gateway Object for accessing the DEMIS Cluster |
| <a name="output_istio_gateway_name"></a> [istio\_gateway\_name](#output\_istio\_gateway\_name) | The name of the Istio Gateway Object for accessing the DEMIS Cluster |
| <a name="output_keycloak_svc_hostname"></a> [keycloak\_svc\_hostname](#output\_keycloak\_svc\_hostname) | The Internal Service Hostname for the Keycloak Service |
| <a name="output_meldung_hostname"></a> [meldung\_hostname](#output\_meldung\_hostname) | The URL for accessing the DEMIS Notification Portal over Internet |
| <a name="output_portal_hostname"></a> [portal\_hostname](#output\_portal\_hostname) | The URL for accessing the DEMIS Notification Portal over the Telematikinfrastruktur (TI) |
| <a name="output_storage_hostname"></a> [storage\_hostname](#output\_storage\_hostname) | The URL for accessing the S3 compatible storage (minio) |
| <a name="output_ti_idp_hostname"></a> [ti\_idp\_hostname](#output\_ti\_idp\_hostname) | The URL for performing the login over the Telematikinfrastruktur (TI) |
| <a name="output_tls_hostnames"></a> [tls\_hostnames](#output\_tls\_hostnames) | The Hostnames for TLS-only Connections |
<!-- END_TF_DOCS -->