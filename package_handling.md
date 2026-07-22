<img align="right" alt="gematik" width="250" height="47" src="media/Gematik_Logo_Flag.png"/> <br/>    

# Profile Handling and Update Processes

- [General](#general)
- [Profile Provisioning Modes](#profile-provisioning-modes)
- [package Update Process](#package-update-process)
    - [futs](#futs)
    - [validation-service](#validation-service)
        - [Case: Change alternative packages with inplace change of packages (not recommended for production)](#case-change-alternative-packages-with-inplace-change-of-packages-not-recommended-for-production)
        - [Case: Change alternative packages with canary change of packages (recommended for production)](#case-change-alternative-packages-with-canary-change-of-packages-recommended-for-production)
        - [Case: Change app versions with alternative packages without changing alternative packages (recommended for production)](#case-change-app-versions-with-alternative-packages-without-changing-alternative-packages-recommended-for-production)
        - [Case: Change app versions with alternative packages with changing alternative packages (recommended for production)](#case-change-app-versions-with-alternative-packages-with-changing-alternative-packages-recommended-for-production)

## General
This Project supports deployment of multiple fhir packages for specific services. The Services futs and validation-service supports fhir packages. Regularly this will be defined in stage configuration under [./environments](./environments) folder in active-versions.yaml in following sections:
```yaml
futs-pathogen:
  main:
    version: 5.3.5-b114
    weight: 100
    profiles:
      - 6.1.7-b2
  canary: {}
validation-service-pathogen:
  main:
    version: 3.1.1-b3
    weight: 100
    profiles:
      - 6.1.7-b2
      - 5.3.2-b108
  canary: {}
```
this will provide package change for only one specific fhir package by exchange the profiles property in main or canary section. futs only supports one package.

For alternative package or multiple package usage definition it's possible to define extra properties like:

```yaml
validation-service-disease:
  main:
    version: 2.9.0
    weight: 100
    profiles:
      - 6.1.4-b8
      - 5.3.2-b108
  canary:
    profiles:
      - 6.1.7-b2
      - 5.3.2-b108
```

The profiles property is not optional and supports canary deployments for package, with or without changing the app version.

## Profile Provisioning Modes
The validation-service supports multiple packages, provisioning of packages could be done in modes:

- dedicated: A single service instance supports all packages. This increases resource usage for that instance, lengthens startup time, and can increase processing time per request.
- distributed: Each package is supported by its own service instance. This results in more service instances and overall resource usage, but less resource usage per instance, shorter startup times, and potentially lower processing time per request.
- combined: Mixes both modes. One dedicated instance supports all packages, and additional distributed instances support individual packages. This increases the total number of instances and overall resource usage, while offering maximum flexibility for handling package validation requests.

the modes can be defined under specific ([./environments](./environments)) in application-configuration.tfvars for the validation services like:

```hcl
# settings for validation service profile provisioning mode
# null disabled the profile provisioning mode and deploy in old mode
# possible values are: dedicated, distributed, combined
profile_provisioning_mode_vs_disease      = "combined"
profile_provisioning_mode_vs_pathogen     = "combined"
profile_provisioning_mode_vs_bedoccupancy = "combined"
profile_provisioning_mode_vs_igs          = "combined"
profile_provisioning_mode_vs_ars          = "combined"
```

## Profile Update Process

### futs

The futs service supports only one package. The package can be set by specifying the package version in the futs service section of active-versions.yaml, like:

```yaml
futs-disease:
  main:
    version: 2.2.4-b323
    weight: 100
    profiles:
      - 6.1.7-b2
  canary: {}
```

in this case the default package will not be used and only the first item in packages list will be used.

### validation-service
The validation service supports multiple packages. For multiple packages, they can be specified in the validation-service section of active-versions.yaml, like:

```yaml
validation-service-disease:
  main:
    version: 2.9.0
    weight: 100
    profiles:
      - 6.1.4-b8
      - 5.3.2-b108
  canary:
    profiles:
      - 6.1.7-b2
      - 5.3.2-b108
```
#### Case: Change alternative packages with inplace change of packages (not recommended for production)
initial state:
```diff
validation-service-disease:
  main:
    version: 2.9.0
    weight: 100
    profiles:
-     - 6.1.4-b8
+     - 6.1.7-b2
      - 5.3.2-b108
    canary: {}
```
during the upgrade, services for package 6.1.4-b8 will be deleted before services for package 6.1.7-b2 are created in the dedicated or distributed profile provisioning modes. This can cause temporary unavailability of the validation service for v6 endpoints. The result will be:
```yaml
validation-service-disease:
  main:
    version: 2.9.0
    weight: 100
    profiles:
      - 6.1.7-b2
      - 5.3.2-b108
    canary: {}
```
#### Case: Change alternative packages with canary change of packages (recommended for production)
initial state:
```diff
validation-service-disease:
  main:
    version: 2.9.0
    weight: 100
    profiles:
      - 6.1.4-b8
      - 5.3.2-b108
- canary: {}
+ canary:
+   profiles:
+     - 6.1.7-b2
+     - 5.3.2-b108
```
during the upgrade, services for package 6.1.7-b2 will be created in both provisioning modes: dedicated (upgraded to support all packages from main and canary) and distributed. The traffic transfer action will move the canary packages to main when the status is:
```diff
validation-service-disease:
  main:
    version: 2.9.0
    weight: 100
    profiles:
-     - 6.1.4-b8
      - 5.3.2-b108
+     - 6.1.7-b2
- canary:
-   profiles:
-     - 6.1.7-b2
-     - 5.3.2-b108
+ canary: {}
```
during the upgrade, services for package 6.1.4-b8 will be deleted after services for package 6.1.7-b2 are created in the dedicated provisioning mode (upgraded to support all packages from main) and in the distributed mode. This prevents temporary unavailability of the validation service for v6 endpoints. The result will be:
```yaml
validation-service-disease:
  main:
    version: 2.9.0
    weight: 100
    profiles:
      - 6.1.7-b2
      - 5.3.2-b108
  canary: {}
```
#### Case: Change app versions with alternative packages without changing alternative packages (recommended for production)
initial state:
```diff
validation-service-disease:
  main:
    version: 2.9.0
    weight: 100
    profiles:
      - 6.1.4-b8
      - 5.3.2-b108
- canary: {}
+ canary:
+   version: 2.9.1
+   weight: 0
```
after the upgrade, validation-service version 2.9.1 will be created with the packages defined in the main section, using the dedicated provisioning mode (upgraded to support all main packages) and the distributed mode in canary. After a successful traffic switch, the old version 2.9.0 will be deleted. The result will be:
```yaml
validation-service-disease:
  main:
    version: 2.9.1
    weight: 100
    profiles:
      - 6.1.4-b8
      - 5.3.2-b108
  canary: {}
```
#### Case: Change app versions with alternative packages with changing alternative packages (recommended for production)
initial state:
```diff
validation-service-disease:
  main:
    version: 2.9.0
    weight: 100
    profiles:
      - 6.1.4-b8
      - 5.3.2-b108
- canary: {}
+ canary:
+   version: 2.9.1
+   weight: 0
+   profiles:
+     - 6.1.7-b2
+     - 5.3.2-b108
```
after the upgrade, validation-service version 2.9.1 will be created with the packages defined in the canary section, using the dedicated provisioning mode (upgraded to support all packages from the specified sections) and the distributed mode in canary for each service. After a successful traffic switch, the old version 2.9.0 will be deleted. The result will be:
```yaml
validation-service-disease:
  main:
    version: 2.9.1
    weight: 100
    profiles:
      - 6.1.7-b2
      - 5.3.2-b108
  canary: {}
```
