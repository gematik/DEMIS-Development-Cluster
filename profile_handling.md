<img align="right" alt="gematik" width="250" height="47" src="media/Gematik_Logo_Flag.png"/> <br/>    

# Profile Handling and Update Processes

- [General](#general)
- [Profile Provisioning Modes](#profile-provisioning-modes)
- [Profile Update Process](#profile-update-process)
    - [futs](#futs)
    - [validation-service](#validation-service)
        - [Case: Change app versions with default profiles (recommended for production)](#case-change-app-versions-with-default-profiles-recommended-for-production)
        - [Case: Change default profiles without app version change (recommended for production)](#case-change-default-profiles-without-app-version-change-recommended-for-production)
        - [Case: Change alternative profiles with inplace change of profiles (not recommended for production)](#case-change-alternative-profiles-with-inplace-change-of-profiles-not-recommended-for-production)
        - [Case: Change alternative profiles with canary change of profiles (recommended for production)](#case-change-alternative-profiles-with-canary-change-of-profiles-recommended-for-production)
        - [Case: Change app versions with alternative profiles without changing alternative profiles (recommended for production)](#case-change-app-versions-with-alternative-profiles-without-changing-alternative-profiles-recommended-for-production)
        - [Case: Change app versions with alternative profiles with changing alternative profiles (recommended for production)](#case-change-app-versions-with-alternative-profiles-with-changing-alternative-profiles-recommended-for-production)
        - [Case: Revert to default profile usage (recommended for production)](#case-revert-to-default-profile-usage-recommended-for-production)

## General
This Project supports deployment of multiple fhir profiles for specific services. The Services futs and validation-service supports fhir profiles. Typically only one profile per service. Regularly this will be defined in stage configuration under [./environments](./environments) folder in active-versions.yaml in following sections:
```yaml
fhir-profile-snapshots:
  main:
    version: 5.3.5-b114
    weight: 100
  canary: {}
igs-profile-snapshots:
  main:
    version: 3.1.1-b3
    weight: 100
  canary: {}
ars-profile-snapshots:
  main:
    version: 1.1.1-b22
    weight: 100
  canary: {}
```
this will provide profile change for only one specific fhir profile by exchange the version property in main section.

For alternative profile or multiple profile usage definition it's possible to define extra properties like:

```yaml
validation-service-core:
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

The profiles property is optional and supports canary deployments for profiles, with or without changing the app version. If no profile blocks are defined, the default profile is used.

## Profile Provisioning Modes
The validation-service supports multiple profiles, provisioning of profiles could be done in modes:

- dedicated: A single service instance supports all profiles. This increases resource usage for that instance, lengthens startup time, and can increase processing time per request.
- distributed: Each profile is supported by its own service instance. This results in more service instances and overall resource usage, but less resource usage per instance, shorter startup times, and potentially lower processing time per request.
- combined: Mixes both modes. One dedicated instance supports all profiles, and additional distributed instances support individual profiles. This increases the total number of instances and overall resource usage, while offering maximum flexibility for handling profile validation requests.

the modes can be defined under specific ([./environments](./environments)) in application-configuration.tfvars for the validation services like:

```hcl
# settings for validation service profile provisioning mode
# null disabled the profile provisioning mode and deploy in old mode
# possible values are: dedicated, distributed, combined
profile_provisioning_mode_vs_core = "combined"
profile_provisioning_mode_vs_igs  = "combined"
profile_provisioning_mode_vs_ars  = "combined"
```

## Profile Update Process

### futs

The futs service supports only one profile. The profile is defined in active-versions.yaml under the profile-snapshots section. It is updated by changing the version property in the main section. The update is applied via a Helm upgrade of the FUTS service. Alternatively, the profile can be overridden by specifying the profile version in the futs service section of active-versions.yaml, like:

```yaml
futs-core:
  main:
    version: 2.2.4-b323
    weight: 100
    profiles:
      - 6.1.7-b2
  canary: {}
```

in this case the default profile will not be used and only the first item in profiles list will be used.

### validation-service
The validation service supports multiple profiles. Profiles are defined in active-versions.yaml under the profile-snapshots section. Updates are applied via a Helm upgrade of the validation service. For multiple or alternative profiles, they can be specified in the validation-service section of active-versions.yaml, like:

```yaml
validation-service-core:
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

#### Case: Change app versions with default profiles (recommended for production)

initial state:
```diff
validation-service-core:
  main:
    version: 2.9.0
    weight: 100
- canary: {}
+ canary:
+    version: 2.9.1
+    weight: 0
fhir-profile-snapshots:
  main:
    version: 5.3.5-b114
    weight: 100
  canary: {}
```
after upgrade process of validation-service will be upgraded in canary mode with default profile and result in:
```yaml
validation-service-core:
  main:
    version: 2.9.1
    weight: 100
  canary: {}
fhir-profile-snapshots:
  main:
    version: 5.3.5-b114
    weight: 100
  canary: {}
```
#### Case: Change default profiles without app version change (recommended for production)

initial state:
```diff
validation-service-core:
  main:
    version: 2.9.0
    weight: 100
  canary: {}
fhir-profile-snapshots:
  main:
-   version: 5.3.3-b111
+   version: 5.3.5-b114
    weight: 100
  canary: {}
```
after upgrade process of validation-service will be upgraded without canary mode with default profile and result in:
```yaml
validation-service-core:
  main:
    version: 2.9.0
    weight: 100
  canary: {}
fhir-profile-snapshots:
  main:
    version: 5.3.5-b114
    weight: 100
  canary: {}
```
#### Case: Change alternative profiles with inplace change of profiles (not recommended for production)
initial state:
```diff
validation-service-core:
  main:
    version: 2.9.0
    weight: 100
    profiles:
-     - 6.1.4-b8
+     - 6.1.7-b2
      - 5.3.2-b108
    canary: {}
```
during the upgrade, services for profile 6.1.4-b8 will be deleted before services for profile 6.1.7-b2 are created in the dedicated or distributed profile provisioning modes. This can cause temporary unavailability of the validation service for v6 endpoints. The result will be:
```yaml
validation-service-core:
  main:
    version: 2.9.0
    weight: 100
    profiles:
      - 6.1.7-b2
      - 5.3.2-b108
    canary: {}
```
#### Case: Change alternative profiles with canary change of profiles (recommended for production)
initial state:
```diff
validation-service-core:
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
during the upgrade, services for profile 6.1.7-b2 will be created in both provisioning modes: dedicated (upgraded to support all profiles from main and canary) and distributed. The traffic transfer action will move the canary profiles to main when the status is:
```diff
validation-service-core:
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
during the upgrade, services for profile 6.1.4-b8 will be deleted after services for profile 6.1.7-b2 are created in the dedicated provisioning mode (upgraded to support all profiles from main) and in the distributed mode. This prevents temporary unavailability of the validation service for v6 endpoints. The result will be:
```yaml
validation-service-core:
  main:
    version: 2.9.0
    weight: 100
    profiles:
      - 6.1.7-b2
      - 5.3.2-b108
  canary: {}
```
#### Case: Change app versions with alternative profiles without changing alternative profiles (recommended for production)
initial state:
```diff
validation-service-core:
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
after the upgrade, validation-service version 2.9.1 will be created with the profiles defined in the main section, using the dedicated provisioning mode (upgraded to support all main profiles) and the distributed mode in canary. After a successful traffic switch, the old version 2.9.0 will be deleted. The result will be:
```yaml
validation-service-core:
  main:
    version: 2.9.1
    weight: 100
    profiles:
      - 6.1.4-b8
      - 5.3.2-b108
  canary: {}
```
#### Case: Change app versions with alternative profiles with changing alternative profiles (recommended for production)
initial state:
```diff
validation-service-core:
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
after the upgrade, validation-service version 2.9.1 will be created with the profiles defined in the canary section, using the dedicated provisioning mode (upgraded to support all profiles from the specified sections) and the distributed mode in canary for each service. After a successful traffic switch, the old version 2.9.0 will be deleted. The result will be:
```yaml
validation-service-core:
  main:
    version: 2.9.1
    weight: 100
    profiles:
      - 6.1.7-b2
      - 5.3.2-b108
  canary: {}
```
#### Case: revert to default profile usage (recommended for production)
initial state:
```diff
validation-service-core:
  main:
    version: 2.9.0
    weight: 100
    profiles:
      - 6.1.4-b8
      - 5.3.2-b108
- canary: {}
+ canary:
+   profiles: null
fhir-profile-snapshots:
  main:
    version: 5.3.5-b114
    weight: 100
  canary: {}
```
after upgrade process of validation-service will be upgraded in canary mode with default profile and result in:
```yaml
validation-service-core:
  main:
    version: 2.9.0
    weight: 100
  canary: {}
fhir-profile-snapshots:
  main:
    version: 5.3.5-b114
    weight: 100
  canary: {}
```
