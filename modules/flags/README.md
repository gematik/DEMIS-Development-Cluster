# flags

Module responsible for ordering Feature and Configuration Flags per service, so these can be used to inject values in Helm Charts.

**Important**: the Feature Flags must contain the prefix `FEATURE_FLAG_` in their name as well for the Configuration options it is highly suggested for them to contain the prefix `CONFIG_`

## Usage

In your Project, create a new `module` Block and pass the desired information:

```hcl
module "demis_flags" {
    source = "/path/to/this/module"
    # Define configuration flags
    config_options = [
      {
        services     = ["service1", "service2"],
        option_name  = "CONFIG_CONNECTION_TIMEOUT",
        option_value = "30000"
      },
      {
        services     = ["service2"],
        option_name  = "CONFIG_ENABLED_ENDPOINTS",
        option_value = "a,b,c,d"
      }
    ]

    feature_flags = [
      {
        services   = ["service1", "service2"],
        flag_name  = "FEATURE_FLAG_ENABLE_VALIDATION",
        flag_value = true
      }
    ]
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

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_options"></a> [config\_options](#input\_config\_options) | Defines a list of configuration options that belong to services | <pre>list(object({<br/>    services     = list(string)<br/>    option_name  = string<br/>    option_value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_feature_flags"></a> [feature\_flags](#input\_feature\_flags) | Defines a list of feature flags that belong to services | <pre>list(object({<br/>    services   = list(string)<br/>    flag_name  = string<br/>    flag_value = bool<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_config_options"></a> [service\_config\_options](#output\_service\_config\_options) | Map containing all the configuration options, grouped by service |
| <a name="output_service_feature_flags"></a> [service\_feature\_flags](#output\_service\_feature\_flags) | Map containing all the feature flags, grouped by service |
<!-- END_TF_DOCS -->