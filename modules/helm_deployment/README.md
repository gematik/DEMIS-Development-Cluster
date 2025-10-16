# helm_deployment_canary

Module to perform the deployment of Services using a Canary (or Blue/Green) Deployment approach. It deploys the Helm Chart of a main version of an application and, if defined, also a canary version. The cleanup follows automatically, when one of the versions is not desired anymore.

It offers the possibility of configuring Istio Routing Rules based on the gematik Helm Chart "istio-routing-rulse", if a valid version of the chart is given as input variable.

## Usage

In your Project, create a new `module` Block and pass the desired information, for example to deploy a `nginx` instance:

```hcl
module "nginx" {
    source = "/path/to/this/module"

    namespace = "demis"
    helm_settings = {
      chart_image_tag_property_name = "image.tag"
      helm_repository               = "https://charts.bitnami.com/bitnami"
      deployment_timeout            = 300
    }

    application_name = "nginx"
    deployment_information = {
      deployment-strategy = "canary"
      main = {
        # Your previous version
        version = "1.26.0"
        weight  = 100
      }
      canary = {
        # Your newer version
        version = "1.27.0"
        weight  = 0
      }
    }

    application_values = <<EOT
    image:
      pullPolicy: Always
    extraEnvVars:
      - name: LOG_LEVEL
        value: error
    EOT
}
```

You can add your custom settings, such as:

- Docker Registry
- Image Labels and Annotations
- Pull Secrets
- Pull Policy

with the input variable `application_values`. This variable expects a string in YAML format that contains the required information, necessary to deploy the application in a Kubernetes Cluster. For Pull Secrets, be sure that you have configured them properly through separate steps.

You need to pass the property `chart_image_tag_property_name` through the input variable `helm_settings` in order to handle the deployment of multiple versions of the chart automatically.

## Tests

The module contains unit tests that can be executed with the following command: 

```sh
tofu test
```

The tests are pretty limited, since the DEMIS Helm Charts are currently hosted only internally in the gematik Artifact Repository and they are protected by username and password, so they cannot be used directly for testing. In addition, Helm Charts cannot be rendered in the Plan phase, without a real Kubernetes cluster, so only a subset of properties can be validated.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.chart](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.istio](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of the application. This can also correspond to the Helm Chart name. | `string` | n/a | yes |
| <a name="input_application_values"></a> [application\_values](#input\_application\_values) | Custom values in YAML format to override the default configuration for the application Helm Chart | `string` | `""` | no |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Deployment information for managing the main and optional canary version of the application | <pre>object({<br/>    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name<br/>    image-tag           = optional(string) # Optional, uses a different image tag for the deployment<br/>    deployment-strategy = string<br/>    enabled             = bool<br/>    main = object({<br/>      version = string<br/>      weight  = number<br/>    })<br/>    canary = optional(object({<br/>      version = optional(string)<br/>      weight  = optional(string)<br/>    }), {})<br/>  })</pre> | n/a | yes |
| <a name="input_helm_settings"></a> [helm\_settings](#input\_helm\_settings) | Helm Release settings as Object. | <pre>object({<br/>    chart_image_tag_property_name = string                            # the Helm Chart Property Name where the Image Tag is set (e.g. "image.tag")<br/>    helm_repository               = string                            # the Helm Repository URL<br/>    helm_repository_username      = optional(string)                  # optional (required for private registries), the Helm Repository Username<br/>    helm_repository_password      = optional(string)                  # optional (required for private registries), the Helm Repository Password<br/>    istio_routing_chart_version   = optional(string)                  # optional, the Version of the Istio Routing Helm Chart to be installed<br/>    deployment_timeout            = optional(number)                  # optional, the Timeout for creating Helm Release<br/>    istio_routing_chart_name      = optional(string, "istio-routing") # optional, the name of the Istio Routing Helm Chart<br/>    reset_values                  = optional(bool, false)             # optional, whether to reset values to the ones built into the chart<br/>  })</pre> | n/a | yes |
| <a name="input_istio_values"></a> [istio\_values](#input\_istio\_values) | Custom values in YAML format to override the configuration for the Istio Helm Chart | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The Namespace where to install the Helm Chart | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_chart_versions"></a> [app\_chart\_versions](#output\_app\_chart\_versions) | The Versions of deployed Helm Charts |
| <a name="output_istio_version"></a> [istio\_version](#output\_istio\_version) | The Version of the deployed Helm Chart of the Istio Routing Rules |
<!-- END_TF_DOCS -->