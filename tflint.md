<img align="right" alt="gematik" width="250" height="47" src="media/Gematik_Logo_Flag.png"/> <br/>    

# tflint

## general 
tflint is a linter for terraform resources and can be extended by plugins. it will be used to standardize terraform projects. tflint will be configured by configuration file in this projects root ( [.tflint.hcl](./.tflint.hcl) ). the configuration file defines rules and plugins which will be used for linting terraform. the project uses the terraform plugin.

## rules

rules are all explizit setted for preventing unknown changes by plugin provider.

**available changes are:**

|Rule|Description|Recommended|activated|notes|
| --- | --- | --- | --- | --- |
|terraform_comment_syntax|Disallow `//` comments in favor of `#`||||
|terraform_deprecated_index|Disallow legacy dot index syntax|✔|✔||
|terraform_deprecated_interpolation|Disallow deprecated (0.11-style) interpolation|✔|✔||
|terraform_deprecated_lookup|Disallow deprecated `lookup()` function with only 2 arguments.|✔|✔||
|terraform_documented_outputs|Disallow `output` declarations without description||✔|for proper documentation its enabled|
|terraform_documented_variables|Disallow `variable` declarations without description||✔|for proper documentation its enabled|
|terraform_empty_list_equality|Disallow comparisons with `[]` when checking if a collection is empty|✔|✔||
|terraform_map_duplicate_keys|Disallow duplicate keys in a map object|✔|✔||
|terraform_module_pinned_source|Disallow specifying a git or mercurial repository as a module source without pinning to a version|✔|✔||
|terraform_module_version|Checks that Terraform modules sourced from a registry specify a version|✔|✔||
|terraform_naming_convention|Enforces naming conventions for resources, data sources, etc||✔|for setting snake_case naming convention it will be activated and setted explicit.|
|terraform_required_providers|Require that all providers have version constraints through required_providers|✔|✔||
|terraform_required_version|Disallow `terraform` declarations without require_version|✔|✔||
|terraform_standard_module_structure|Ensure that a module complies with the Terraform Standard Module Structure|||it will force stucture changes for code like no specific variable files. for better maintenance aspectives this flag is disabled|
|terraform_typed_variables|Disallow `variable` declarations without type|✔|✔||
|terraform_unused_declarations|Disallow variables, data sources, and locals that are declared but never used|✔|✔||
|terraform_unused_required_providers|Check that all `required_providers` are used in the module||✔|cleans up the code|
|terraform_workspace_remote|`terraform.workspace` should not be used with a "remote" backend with remote execution in Terraform v1.0.x|✔|✔||

## usage

before tflint could be used with specific provider plugins an initialization is required. the initialization will install the defined provider plugins. the initialization could be done by:

```shell
tflint --init
```

after initialization tflint could linting the terraform files. to prevent extra execution in each terraform folder, tflint supports recursive execution mode. tflint could be executed in root directory by:

```shell
tflint --recursive --config="$(realpath ./.tflint.hcl)" --minimum-failure-severity=warning
```

also could be used by executing shell script in [.scripts/tflint.sh](./.scripts/tflint.sh)

```shell
sh -c "bash .scripts/tflint.sh"
```

# resources

* [tflint](https://github.com/terraform-linters/tflint)
* [tflint-ruleset-terraform](https://github.com/terraform-linters/tflint-ruleset-terraform)
