# pull_secret

Module responsible for creating one or more Kubernetes Secret Objects containing Image Pull Secrets in a Kubernetes Cluster, given external username and password, JSON Tokens or OAuth Tokens (e.g. for Google Artifact Registries).

**Important Notice**: Even though the password input variable is treated as sensitive, consider injecting the value through an environment variable. The module itself does not outputs the content of the created Secret Object, but only its metadata information. For additional security, it's highly recommended to encrypt your State File and Credentials that only allow reading access to a registry.

## Usage

In your Project, create a new `module` Block and pass the expected credentials, e.g. for Google Artifact Hub:

```hcl
module "gcp_pull_secret" {
    source = "/path/to/this/module"

    namespace = "your-namespace"
    name          = "your-pull-secret-name"
    registry      = "your-docker-registry-url"
    user_name     = "test-user"             # For Google Cloud with an OAuth Token, use "oauth2accesstoken", for JSON Keys, "_json_key"
    user_email    = "your-email@domain.com" # Please set your email address here
    user_password = "your-password"         # When using an OAuth Token, set the token here. For JSON Key, use the JSON Key itself, base64 encoded.
    password_type = "plain"                 # For Access Token, use "token", for JSON Key, use "json_key"
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_secret_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annotations"></a> [annotations](#input\_annotations) | The Annotations to apply to the Secret | `map(string)` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | The Labels to apply to the Secret | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The Name of the Pull Secret | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The Namespace to use for deployment | `string` | n/a | yes |
| <a name="input_password_type"></a> [password\_type](#input\_password\_type) | This variable defines the type of user password used for the Pull Secret. It accepts one of the following values: "json\_key", "gcloud\_token", or "plain".<br/><br/>  * "token": If selected, the `user_password` variable should contain an Access Token. This token is typically generated using the command, e.g. for Google Cloud, `gcloud auth print-access-token`.<br/>  * "json\_key": If selected, the `user_password` variable should contain the base64 encoded content of a JSON Key file. Ensure that the JSON Key file is encoded correctly before assigning it to this variable.<br/>  * "plain": If selected, the `user_password` variable should contain a plain text password.<br/><br/>  Choose the appropriate type based on your authentication method. | `string` | n/a | yes |
| <a name="input_registry"></a> [registry](#input\_registry) | The Registry to use for the Pull Secret | `string` | n/a | yes |
| <a name="input_user_email"></a> [user\_email](#input\_user\_email) | The User E-Mail Address to use for the Pull Secret | `string` | n/a | yes |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | The User Name to use for the Pull Secret | `string` | n/a | yes |
| <a name="input_user_password"></a> [user\_password](#input\_user\_password) | The User Password to use for the Pull Secret | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metadata"></a> [metadata](#output\_metadata) | Prints the metadata information of the generated Kubernetes Secret for the Pull Credentials. |
<!-- END_TF_DOCS -->