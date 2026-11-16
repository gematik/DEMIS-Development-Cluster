# audit-log-service

Deploys the Audit Log Service into the observability namespace. Its ext_proc EnvoyFilters are placed in the Istio root namespace and restricted via `proxy.metadata.NAMESPACE` to the audited namespace, since that namespace does not exist yet when the infrastructure is deployed.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_deployment"></a> [deployment](#module\_deployment) | ../../modules/helm_deployment | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_audited_namespace"></a> [audited\_namespace](#input\_audited\_namespace) | Namespace of the audited workloads (fhir-storage-reader/-writer) | `string` | `"demis"` | no |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Deployment information of the Audit Log Service from the active-versions.yaml (as for modules/helm\_deployment) | `any` | n/a | yes |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | Docker registry of the Audit Log Service image | `string` | n/a | yes |
| <a name="input_filter_namespace"></a> [filter\_namespace](#input\_filter\_namespace) | Namespace of the ext\_proc EnvoyFilters; the Istio root namespace, so they reach the audited namespace | `string` | `"istio-system"` | no |
| <a name="input_fssr_enabled"></a> [fssr\_enabled](#input\_fssr\_enabled) | Audits the read access of the fhir-storage-reader | `bool` | `false` | no |
| <a name="input_fssw_enabled"></a> [fssw\_enabled](#input\_fssw\_enabled) | Audits the write access of the fhir-storage-writer | `bool` | `false` | no |
| <a name="input_helm_password"></a> [helm\_password](#input\_helm\_password) | Password for the Helm Chart Repository | `string` | `null` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | Helm Chart Repository URL or repository name of the Audit Log Service | `string` | n/a | yes |
| <a name="input_helm_username"></a> [helm\_username](#input\_helm\_username) | Username for the Helm Chart Repository | `string` | `null` | no |
| <a name="input_image_pull_secrets"></a> [image\_pull\_secrets](#input\_image\_pull\_secrets) | Names of the image pull secrets in the target namespace | `list(string)` | `[]` | no |
| <a name="input_istio_routing_deployment_information"></a> [istio\_routing\_deployment\_information](#input\_istio\_routing\_deployment\_information) | Deployment information of the istio-routing chart from the active-versions.yaml, creates the Service of the Audit Log Service | `any` | n/a | yes |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of Audit Log Service replicas | `number` | `1` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | Namespace where to install the Audit Log Service | `string` | `"observability"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_service_url"></a> [service\_url](#output\_service\_url) | The Cluster-internal gRPC address of the Audit Log Service |
<!-- END_TF_DOCS -->
