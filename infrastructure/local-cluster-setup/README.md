# local-cluster-setup

Terraform Module for creating a local Kubernetes Cluster using KIND (Kubernetes In Docker).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.6.0 |
| <a name="requirement_kind"></a> [kind](#requirement\_kind) | >= 0.7.0, < 1.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kind_cluster.cluster](https://registry.terraform.io/providers/tehcyx/kind/latest/docs/resources/cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kind_cluster_name"></a> [kind\_cluster\_name](#input\_kind\_cluster\_name) | Defines the name of the local KIND cluster | `string` | n/a | yes |
| <a name="input_kind_image_tag"></a> [kind\_image\_tag](#input\_kind\_image\_tag) | Defines the KIND Image Tag to use | `string` | `"v1.27.16"` | no |
| <a name="input_kind_worker_nodes"></a> [kind\_worker\_nodes](#input\_kind\_worker\_nodes) | Defines the number of KIND Worker Nodes to be created | `number` | `2` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kind_endpoint"></a> [kind\_endpoint](#output\_kind\_endpoint) | The Kubernetes API Endpoint |
| <a name="output_kind_version"></a> [kind\_version](#output\_kind\_version) | The version of KIND Image |
| <a name="output_kind_worker_nodes"></a> [kind\_worker\_nodes](#output\_kind\_worker\_nodes) | The number of KIND Worker Nodes |
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | The kubeconfig path for the cluster |
<!-- END_TF_DOCS -->