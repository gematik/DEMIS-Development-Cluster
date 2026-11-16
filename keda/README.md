# keda

Module responsible for configuring and deploying KEDA (Kubernetes Event-driven Autoscaling) in a Kubernetes Cluster.

KEDA is optional per stage: it is only deployed if the stage provides a `keda` folder. Stages without it are
skipped entirely by the Makefile targets (`init-keda`, `keda`, `cleanup-keda`). `make create-local-environment`
additionally skips KEDA if `DEPLOY_KEDA=false` is set (default: `true`).
In this stage, KEDA is only started and does not scale any workload yet.

It performs the following operations:

- creates the Namespace `keda` (without Istio Sidecar Injection, since the kube-apiserver calls the KEDA metrics API and webhooks directly)
- creates the Pull Secrets for the mirrored KEDA images
- creates a ResourceQuota allowing the built-in system PriorityClass outside of `kube-system`
- deploys the DEMIS KEDA Helm Chart (including the KEDA CRDs)

Removing KEDA (`make <stage> cleanup-keda`) deletes the Helm Release and the Namespace, the KEDA CRDs are kept (see the README of the DEMIS KEDA Chart).

## Versioning

The version is read from `environments/stage-<stage>/keda/active-versions.yaml` and kept up to date by the
update pipelines (`copyVersions.sh`, `deployment-strategy: update`). KEDA runs as a single cluster-wide operator,
so only `main` is supported (no canary). The images share the version of the Chart; `image-tag` overrides it.

```yaml
keda:
  main:
    version: 2.21.0-b5
    weight: 100
  canary: {}
  deployment-strategy: update
  # optional, for local tests with a local Chart directory
  # chart-name: /mnt/c/dev/demis/keda/deployment/helm/keda
```

## Stage-specific Helm values

The Helm values are defined like the `applications` of the other modules. The default template
`applications/keda/app-values.tftpl.yaml` contains the values managed by this module (image tags, pull secrets,
PriorityClass, registry). Operator, metrics API server and admission webhooks are part of the same Helm Release,
so a single values file configures all three components. Like for the other DEMIS services, the images are pulled
from `docker_registry`; on Docker Hub (`docker.io/gematik1`) they are published with the prefix `demis-`
(e.g. `demis-keda-operator`). Stages can provide in `environments/stage-<stage>/keda/keda/`:

- `app-values.yaml` (recommended): applied on top of the template, containing only the differing values
- `app-values.tftpl.yaml`: replaces the default template completely, it must keep the managed values

```yaml
# environments/stage-<stage>/keda/keda/app-values.yaml
keda:
  operator:
    replicaCount: 2
  resources:
    operator:
      limits:
        memory: 2000Mi
  logging:
    operator:
      level: debug
```

Scaling definitions (`ScaledObject`, `TriggerAuthentication`) are not part of this module: they must be created
in the Namespace of the scaled workload and belong to the Helm Charts of the respective services.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.3.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_keda_namespace"></a> [keda\_namespace](#module\_keda\_namespace) | ../modules/namespace | n/a |
| <a name="module_keda_namespace_quota"></a> [keda\_namespace\_quota](#module\_keda\_namespace\_quota) | ../modules/namespace_quota | n/a |
| <a name="module_pull_secrets"></a> [pull\_secrets](#module\_pull\_secrets) | ../modules/pull_secret | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.keda](https://registry.terraform.io/providers/hashicorp/helm/3.3.0/docs/resources/release) | resource |
| [kubernetes_resource_quota_v1.priority_class](https://registry.terraform.io/providers/hashicorp/kubernetes/3.3.0/docs/resources/resource_quota_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_docker_pull_secrets"></a> [docker\_pull\_secrets](#input\_docker\_pull\_secrets) | This Object contains the definition of Pull Secrets for accessing private repositories and pull Docker Images, using credentials.<br/><br/>  For credentials-based secrets, if the field "password\_type" is "token", <br/>  then the value of the variable "google\_cloud\_access\_token" will be used instead.<br/><br/>  If the field "password\_type" is set to "json\_key", the value of the field "user\_password" will be used as a Base64-encoded JSON Key. | <pre>list(object({<br/>    name          = string<br/>    registry      = string<br/>    user_name     = string<br/>    user_email    = string<br/>    user_password = string<br/>    password_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | The Docker Registry to use for pulling Images | `string` | n/a | yes |
| <a name="input_google_cloud_access_token"></a> [google\_cloud\_access\_token](#input\_google\_cloud\_access\_token) | The User-Token for accessing the Google Artifact Registry. <br/>  Typically obtained with the command: 'gcloud auth print-access-token' | `string` | `""` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The Helm Repository where is stored the Helm Chart | `string` | n/a | yes |
| <a name="input_helm_repository_name"></a> [helm\_repository\_name](#input\_helm\_repository\_name) | The repository name in the Helm repositories.yaml, used if helm\_repository\_source is 'local' | `string` | `"demis"` | no |
| <a name="input_helm_repository_password"></a> [helm\_repository\_password](#input\_helm\_repository\_password) | The Password credential for the Helm Repository | `string` | `""` | no |
| <a name="input_helm_repository_source"></a> [helm\_repository\_source](#input\_helm\_repository\_source) | Where Helm Charts are resolved from: 'url' uses helm\_repository with the credentials from credentials.tfvars, 'local' uses the repository name helm\_repository\_name from the Helm repositories.yaml (credentials and index cache are taken from there) | `string` | `"url"` | no |
| <a name="input_helm_repository_username"></a> [helm\_repository\_username](#input\_helm\_repository\_username) | The Username credential for the Helm Repository | `string` | `""` | no |
| <a name="input_keda_priority_class_name"></a> [keda\_priority\_class\_name](#input\_keda\_priority\_class\_name) | The PriorityClass for all KEDA components, so KEDA keeps running in the DEGRADED/EMERGENCY modes. Built-in classes (system-*) are allowed by a dedicated ResourceQuota. Empty disables the PriorityClass. | `string` | `"system-cluster-critical"` | no |
| <a name="input_kms_encryption_key"></a> [kms\_encryption\_key](#input\_kms\_encryption\_key) | The GCP KMS encryption key for OpenTofu state encryption | `string` | `""` | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig file for the cluster | `string` | `""` | no |
| <a name="input_namespace_resource_quota"></a> [namespace\_resource\_quota](#input\_namespace\_resource\_quota) | Resource quota configuration for the target Namespace. Set to null to skip quota creation. | <pre>object({<br/>    limits_cpu      = optional(string)<br/>    limits_memory   = optional(string)<br/>    requests_cpu    = optional(string)<br/>    requests_memory = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_override_stage_name"></a> [override\_stage\_name](#input\_override\_stage\_name) | Override the automatically detected stage name (optional) | `string` | `""` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | The Namespace to use for the deployment of KEDA | `string` | `"keda"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_keda_chart_version"></a> [keda\_chart\_version](#output\_keda\_chart\_version) | The deployed version of the DEMIS KEDA Chart |
| <a name="output_keda_namespace"></a> [keda\_namespace](#output\_keda\_namespace) | The Namespace of the KEDA deployment |
| <a name="output_kms_encryption_key_used"></a> [kms\_encryption\_key\_used](#output\_kms\_encryption\_key\_used) | The flag to indicate if the KMS encryption key is used |
| <a name="output_stage_name"></a> [stage\_name](#output\_stage\_name) | Current stage |
<!-- END_TF_DOCS -->
