# infrastructure

Terraform Project to configure a Kubernetes Cluster with Service Mesh and optional Security Tools.

It performs the following operations:

- creates a local Kubernetes cluster (for local development only)
- creates a service account for a remote cluster
- creates a Namespace where to deploy the Service Meshes components ("istio-system")
- creates an optional Namespace where to deploy Security related services ("security")
- installs the Service Mesh Components:
  - Istio
  - Jaeger
  - Kiali
  - Prometheus (optional)
  - Grafana (optional)
- installs the Security components (optional):
  - Trivy Operator
  - Falco

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.37.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_falco"></a> [falco](#module\_falco) | ./security/falco | n/a |
| <a name="module_istio_metadata"></a> [istio\_metadata](#module\_istio\_metadata) | ../modules/metadata | n/a |
| <a name="module_istio_namespace"></a> [istio\_namespace](#module\_istio\_namespace) | ../modules/namespace | n/a |
| <a name="module_kyverno"></a> [kyverno](#module\_kyverno) | ./kyverno-controller | n/a |
| <a name="module_kyverno_namespace"></a> [kyverno\_namespace](#module\_kyverno\_namespace) | ../modules/namespace | n/a |
| <a name="module_kyverno_policy_reporter"></a> [kyverno\_policy\_reporter](#module\_kyverno\_policy\_reporter) | ./security/policy-reporter | n/a |
| <a name="module_local_cluster"></a> [local\_cluster](#module\_local\_cluster) | ./local-cluster-setup | n/a |
| <a name="module_pull_secrets"></a> [pull\_secrets](#module\_pull\_secrets) | ../modules/pull_secret | n/a |
| <a name="module_remote_cluster"></a> [remote\_cluster](#module\_remote\_cluster) | ./remote-cluster-setup | n/a |
| <a name="module_security_metadata"></a> [security\_metadata](#module\_security\_metadata) | ../modules/metadata | n/a |
| <a name="module_security_namespace"></a> [security\_namespace](#module\_security\_namespace) | ../modules/namespace | n/a |
| <a name="module_service_mesh"></a> [service\_mesh](#module\_service\_mesh) | ./service-mesh | n/a |
| <a name="module_trivy"></a> [trivy](#module\_trivy) | ./security/trivy | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_region"></a> [cluster\_region](#input\_cluster\_region) | The name of the region where the cluster is deployed | `string` | n/a | yes |
| <a name="input_cluster_role_name"></a> [cluster\_role\_name](#input\_cluster\_role\_name) | Defines the Cluster Role Name to be configured | `string` | `"api-cluster-role"` | no |
| <a name="input_docker_pull_secrets"></a> [docker\_pull\_secrets](#input\_docker\_pull\_secrets) | This Object contains the definition of Pull Secrets for accessing private repositories and pull Docker Images, using credentials.<br/><br/>  For credentials-based secrets, if the field "password\_type" is "token", <br/>  then the value of the variable "google\_cloud\_access\_token" will be used instead.<br/><br/>  If the field "password\_type" is set to "json\_key", the value of the field "user\_password" will be used as a Base64-encoded JSON Key. | <pre>list(object({<br/>    name          = string<br/>    registry      = string<br/>    user_name     = string<br/>    user_email    = string<br/>    user_password = string<br/>    password_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_falco_driver_kind"></a> [falco\_driver\_kind](#input\_falco\_driver\_kind) | sets the specfifc driver kind of the probe inside the nodes. Default of Falco is auto. The options are: kmod, ebpf, modern\_ebpf, We can enforce that if needed. | `string` | `"auto"` | no |
| <a name="input_falco_enabled"></a> [falco\_enabled](#input\_falco\_enabled) | Activates/Deactivates the deployment of Falco | `bool` | `false` | no |
| <a name="input_falco_falcosidekick_enabled"></a> [falco\_falcosidekick\_enabled](#input\_falco\_falcosidekick\_enabled) | enables falcosidekick | `bool` | `false` | no |
| <a name="input_falco_falcosidekick_ui_enabled"></a> [falco\_falcosidekick\_ui\_enabled](#input\_falco\_falcosidekick\_ui\_enabled) | enables falcosidekick | `bool` | `false` | no |
| <a name="input_falco_kubernetes_meta_collector"></a> [falco\_kubernetes\_meta\_collector](#input\_falco\_kubernetes\_meta\_collector) | enables the k8s metacollector plugin | `bool` | `true` | no |
| <a name="input_google_cloud_access_token"></a> [google\_cloud\_access\_token](#input\_google\_cloud\_access\_token) | The User-Token for accessing the Google Artifact Registry. <br/>  Typically obtained with the command: 'gcloud auth print-access-token' | `string` | `""` | no |
| <a name="input_kind_cluster_name"></a> [kind\_cluster\_name](#input\_kind\_cluster\_name) | Defines the name of the local KIND cluster | `string` | `""` | no |
| <a name="input_kind_image_tag"></a> [kind\_image\_tag](#input\_kind\_image\_tag) | Defines the KIND Image Tag to use. | `string` | `"v1.32.2"` | no |
| <a name="input_kind_worker_nodes"></a> [kind\_worker\_nodes](#input\_kind\_worker\_nodes) | Defines the number of KIND Worker Nodes to be created | `number` | `2` | no |
| <a name="input_kms_encryption_key"></a> [kms\_encryption\_key](#input\_kms\_encryption\_key) | The GCP KMS encryption key for OpenTofu state encryption | `string` | `""` | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig file for the cluster | `string` | `null` | no |
| <a name="input_kyverno_admissioncontroller_replicas"></a> [kyverno\_admissioncontroller\_replicas](#input\_kyverno\_admissioncontroller\_replicas) | setting replicas of admission controller | `number` | `3` | no |
| <a name="input_kyverno_backgroundcontroller_replicas"></a> [kyverno\_backgroundcontroller\_replicas](#input\_kyverno\_backgroundcontroller\_replicas) | setting replicas of background controller | `number` | `2` | no |
| <a name="input_kyverno_cleanupcontroller_replicas"></a> [kyverno\_cleanupcontroller\_replicas](#input\_kyverno\_cleanupcontroller\_replicas) | setting replicas of cleanup controller | `number` | `2` | no |
| <a name="input_kyverno_enabled"></a> [kyverno\_enabled](#input\_kyverno\_enabled) | Activates/Deactivates the deployment of Kyverno | `bool` | `false` | no |
| <a name="input_kyverno_namespace"></a> [kyverno\_namespace](#input\_kyverno\_namespace) | Defines the namespace for Kyverno | `string` | `"kyverno"` | no |
| <a name="input_kyverno_policy_reporter_enabled"></a> [kyverno\_policy\_reporter\_enabled](#input\_kyverno\_policy\_reporter\_enabled) | Activates/Deactivates the deployment of Policy Reporter | `bool` | `false` | no |
| <a name="input_kyverno_reportscontroller_replicas"></a> [kyverno\_reportscontroller\_replicas](#input\_kyverno\_reportscontroller\_replicas) | setting replicas of reports controller | `number` | `2` | no |
| <a name="input_local_cluster"></a> [local\_cluster](#input\_local\_cluster) | Defines if the current setup is for a local cluster (using KIND) | `bool` | `true` | no |
| <a name="input_prometheus_service_url"></a> [prometheus\_service\_url](#input\_prometheus\_service\_url) | The Cluster-internal URL of the Prometheus Instance to be used | `string` | `"http://prometheus:9090"` | no |
| <a name="input_security_namespace"></a> [security\_namespace](#input\_security\_namespace) | Defines the namespace for the Security-related services | `string` | `"security"` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | The Service Account name to be configured | `string` | `"api-service-account"` | no |
| <a name="input_service_mesh_external_ip"></a> [service\_mesh\_external\_ip](#input\_service\_mesh\_external\_ip) | The external IP of the ingress gateway, only single IP is supported | `string` | `""` | no |
| <a name="input_service_mesh_grafana_digest"></a> [service\_mesh\_grafana\_digest](#input\_service\_mesh\_grafana\_digest) | The digest of the Grafana Service to be used | `string` | `""` | no |
| <a name="input_service_mesh_grafana_url"></a> [service\_mesh\_grafana\_url](#input\_service\_mesh\_grafana\_url) | The Cluster-internal URL of the Grafana Instance to be used | `string` | `"http://grafana:3000"` | no |
| <a name="input_service_mesh_grafana_version"></a> [service\_mesh\_grafana\_version](#input\_service\_mesh\_grafana\_version) | The version of Grafana to be installed. | `string` | `""` | no |
| <a name="input_service_mesh_istio_version"></a> [service\_mesh\_istio\_version](#input\_service\_mesh\_istio\_version) | The version of the Istio Helm Chart to be installed. | `string` | n/a | yes |
| <a name="input_service_mesh_istiod_replica_count"></a> [service\_mesh\_istiod\_replica\_count](#input\_service\_mesh\_istiod\_replica\_count) | The number of replicas that have to be configured for the Istiod services | `number` | `3` | no |
| <a name="input_service_mesh_jaeger_digest"></a> [service\_mesh\_jaeger\_digest](#input\_service\_mesh\_jaeger\_digest) | The digest of the Jaeger Service to be used | `string` | n/a | yes |
| <a name="input_service_mesh_jaeger_version"></a> [service\_mesh\_jaeger\_version](#input\_service\_mesh\_jaeger\_version) | The version of Jaeger to be installed. | `string` | n/a | yes |
| <a name="input_service_mesh_kiali_version"></a> [service\_mesh\_kiali\_version](#input\_service\_mesh\_kiali\_version) | The version of the Kiali to be installed. | `string` | n/a | yes |
| <a name="input_service_mesh_monitoring_enabled"></a> [service\_mesh\_monitoring\_enabled](#input\_service\_mesh\_monitoring\_enabled) | Activates/Deactivates the deployment of Monitoring Services | `bool` | `false` | no |
| <a name="input_service_mesh_namespace"></a> [service\_mesh\_namespace](#input\_service\_mesh\_namespace) | Defines the namespace for the Service Mesh services (Istio, Jaeger, Kiali) | `string` | `"istio-system"` | no |
| <a name="input_service_mesh_prometheus_version"></a> [service\_mesh\_prometheus\_version](#input\_service\_mesh\_prometheus\_version) | The version of Prometheus to be installed. | `string` | `""` | no |
| <a name="input_service_mesh_tracing_sampling"></a> [service\_mesh\_tracing\_sampling](#input\_service\_mesh\_tracing\_sampling) | The sampling rate option can be used to control what percentage of requests get reported to your tracing system. <br/>  Please refer to the official documentation: https://istio.io/latest/docs/tasks/observability/distributed-tracing/mesh-and-proxy-config/#customizing-trace-sampling" | `string` | `"1.0"` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | The name of the stage | `string` | n/a | yes |
| <a name="input_trivy_additional_report_fields"></a> [trivy\_additional\_report\_fields](#input\_trivy\_additional\_report\_fields) | Comma separated list of additional fields which can be added to the VulnerabilityReport. Supported parameters: Description, Links, CVSS, Target, Class, PackagePath and PackageType | `string` | `"Description,Links,CVSS,Target,Class,PackagePath,PackageType"` | no |
| <a name="input_trivy_cron_job_schedule"></a> [trivy\_cron\_job\_schedule](#input\_trivy\_cron\_job\_schedule) | Specifies the execution period for the scan for Trivy | `string` | `"0 */6 * * *"` | no |
| <a name="input_trivy_enabled"></a> [trivy\_enabled](#input\_trivy\_enabled) | Activates/Deactivates the deployment of Trivy Operator | `bool` | `false` | no |
| <a name="input_trivy_ignore_unfixed"></a> [trivy\_ignore\_unfixed](#input\_trivy\_ignore\_unfixed) | Specifies that Trivy should show only fixed vulnerabilities, if set to true | `bool` | `false` | no |
| <a name="input_trivy_private_registry_secret_names"></a> [trivy\_private\_registry\_secret\_names](#input\_trivy\_private\_registry\_secret\_names) | Map of namespace:token, tokens are comma seperated which can be used to authenticate in private registries in case if there no imagePullSecrets provided | <pre>list(object({<br/>    namespace = string<br/>    token     = string<br/>  }))</pre> | `[]` | no |
| <a name="input_trivy_scan_jobs_limit"></a> [trivy\_scan\_jobs\_limit](#input\_trivy\_scan\_jobs\_limit) | Defines the maximum number of scan jobs create by the operator | `string` | `"3"` | no |
| <a name="input_trivy_scan_namespaces"></a> [trivy\_scan\_namespaces](#input\_trivy\_scan\_namespaces) | Comma separated list of Namespaces to be scanned by Trivy | `string` | `"demis"` | no |
| <a name="input_trivy_severity_levels"></a> [trivy\_severity\_levels](#input\_trivy\_severity\_levels) | Comma separated list of Namespaces to be scanned by Trivy | `string` | `"UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL"` | no |
| <a name="input_trivy_use_less_resources"></a> [trivy\_use\_less\_resources](#input\_trivy\_use\_less\_resources) | Specifies that Trivy should use less CPU/memory for scanning though it takes more time than normal scanning | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_encryption_key_used"></a> [kms\_encryption\_key\_used](#output\_kms\_encryption\_key\_used) | The flag to indicate if the KMS encryption key is used |
<!-- END_TF_DOCS -->