<img align="right" alt="gematik" width="250" height="47" src="../media/Gematik_Logo_Flag.png"/> <br/>    

# DEMIS Kubernetes Environment
Project to configure a local or remote cluster with the following resources/services:

- Service Mesh (Istio) with Add-ons (Jaeger, Kiali, Grafana, Prometheus)
- Security Components (trivy)
- Virtual Services definition
- Application Deployment

## Requirements
### System Requirements
A Linux-based system using one of these options:

* Windows Users:
  * Windows Subsystem for Linux ([WSL2](https://learn.microsoft.com/en-us/windows/wsl/install))
    * Ubuntu 24.04 LTS distribution preferred
    * Full integration with Windows filesystem
* Linux Users:
  * Any major distribution (Ubuntu, Debian, Arch, etc.)
    * Ubuntu 24.04 LTS distribution preferred
* MacOs Users:
  * Not yet available - Images are not yet built for arm64

### Required Tools
Ensure all necessary tools are installed on your system. This include:

- git
- make
- vim
- curl
- unzip
- gpg
- wget
- jq
- yq
- kubectl
- helm
- tofu (OpenTofu)

Hint:
An installation script is already present in the Project "DEMIS-Development-Cluster", in the folder ".scripts" 
and it's called "install-tools.sh".  You can install the required tools when you checkout the Project for the first time.
Run the script in a WSL2/Linux Shell.
```
chmod +x .scripts/install-tools.sh
.scripts/install-tools.sh
```

Additionally, you need to install Docker, for example [Docker Desktop](https://www.docker.com/products/docker-desktop/) 
or [Docker Engine](https://docs.docker.com/engine/install/) on WSL2.

## Preparing DNS Entries 
Before making changes, you need to identify your current IP address:
* Windows: Use the command "ipconfig /all" in Command Prompt
* Linux: Use the command "ip a" in Terminal

Use your actual network IP address of the Docker Adapter/WSL or the IP address of your active network adapter.

Typically locations:
* Windows: C:\Windows\System32\drivers\etc\hosts
* Linux: /etc/hosts

Add the following lines to the end of the hosts file, with your own IP Address as "<Interface-Ip>":
```
<Interface-Ip> auth.ingress.local
<Interface-Ip> ingress.local
<Interface-Ip> portal.ingress.local
<Interface-Ip> meldung.ingress.local
<Interface-Ip> ti-idp.ingress.local
<Interface-Ip> bundid-idp.ingress.local
<Interface-Ip> storage.ingress.local
```

## Configure Cluster

To configure the environment, you need to prepare the environment as follows:

### Clone this repository
Add your SSH key to your GitHub account and clone the repository using SSH.
```sh
git clone git@github.com:gematik/DEMIS-Development-Cluster.git
```

### Initialize the stage
Once you've checked out the code, go in the folder and run the following command, to initialize the public 
stage environment. For this step you need SSH access to the repository.

```sh
cd DEMIS-Development-Cluster
make local init-stage
```

Now the public stage repository is checked out into the folder `DEMIS-Development-Cluster/environments`.

### Setup the whole environment
To create a new complete Environment, including the KIND Cluster, Service Mesh Services and DEMIS Services, 
you need to run the following command:

```sh
cd DEMIS-Development-Cluster
make create-local-environment
```

### Update only the infrastructure
This command is internally called by the previous one ("Create Environment"), thus it is not necessary to run
it separately, but in case you want to check that the Infrastructure (the KIND Cluster, Istio and Monitoring 
Services) are updated and running, you can use the following command:
```sh
cd DEMIS-Development-Cluster
make local init-stage # updates the current stage repository   
make local infrastructure
```

### Update only the Mesh components
This command is internally called by the "Create Environment" one, thus it is not necessary to run it separately, but in
case you want to check that the Mesh components (the Istio Ingress Gateway, Policies and Network Rules) are updated and 
running, you can use the following command:
```sh
cd DEMIS-Development-Cluster
make local init-stage # updates the current stage repository   
make local mesh
```

### Update only the IDM Services
This command is internally called by the "Create Environment" one, thus it is not necessary to run it separately, but in 
case you want to check that the IDM (Identity Management) components (Keycloak, BundID-IDP, Gematik-IDP, Redis, Policies
and Network Rules) are updated and running, you can use the following command:
```sh
cd DEMIS-Development-Cluster
make local init-stage # updates the current stage repository   
make local idm
```

### Update only the DEMIS Services
You can update the Services in a running KIND Kubernetes Cluster, without destroying and recreating it, using the 
following commands:
```sh
cd DEMIS-Development-Cluster
make local init-stage # updates the current stage repository   
make local services
```

### Usage of K8s Tooling
A kubeconfig file, called `kind-config`, will be automatically generated for the local stage under the folder 
`DEMIS-Development-Cluster/infrastructure`. You can use this file with Tools like Lens or `k9s` or `kubectl` itself.

## Cleanup
The Applications and Cluster can be completely removed, including the running KIND Docker Container, using make, with 
the following command:
```sh
cd DEMIS-Development-Cluster
make cleanup-local-environment
```

If you want to remove only the DEMIS applications, including the "demis" Namespace, PersistenceVolumeClaims, 
Secrets and other Resources, you need to run the following command:
```sh
cd DEMIS-Development-Cluster
make local cleanup-services
```

If you want to remove only the IDM applications (not recommended!), including the "idm" Namespace, PersistenceVolumeClaims, 
Secrets and other Resources, you need to run the following command:
```sh
cd DEMIS-Development-Cluster
make local cleanup-idm
```

## Verifiy Cluster Functionality
To verify that you have successfully configured the DEMIS Environment locally, after the completion of the command 
executed during the step CreateEnvironment, perform the following steps:

1. Open your favorite Browser
2. Navigate to the address https://meldung.ingress.local/portal
3. Dismiss the Warning Message due to the self-signed certificate (depending on the Browser: Accept the Risk)
4. Perform the Login in the Notification Portal, by navigating to https://meldung.ingress.local/withtoken
5. Attempt to send a notification through one of the available Frontend Modules (Disease, Laboratory, Bed Occupancy, IGS)
6. If successful, you should receive a confirmation dialog and your browser will download a PDF Receipt automatically


## EKM-Template

The ekm-template is an example of a deployment module for DEMIS. It includes a demo-service and all needed configuration to include it into the DEMIS environment. Its structure is the same as the other modules idm, demis, etc. but all specific configuration is removed. It includes only the necessary files to deploy a new module in its own namespace in the DEMIS environment. It is meant to be used as a template for creating new modules.

After the environment is initialized, as described in [Configure Cluster](#configure-cluster), the public stage repository is in the folder `DEMIS-Development-Cluster/environments`. It also contains configuration files for the EKM-Template module, located in the folder `ekm-template`.

To create a new deployment module for DEMIS you can copy the ekm-template folder in this repo and the stage-public and rename module and configuration names as you need.

### Deploy / Remove
The Makefile includes commands to deploy and remove the module from the DEMIS environment. These can be used to test the module or as a blueprint for your own module.
To deploy or remove the module, you can use the following commands:
```sh
make local ekm-template # deploys the module
make local cleanup-ekm-template # removes the module
```

### Verify Deployment
After the module is deployed, there should be a new namespace called `ekm-template` in your Kubernetes cluster. In that namespace, a demo service is deployed.

You can verify the service functionality by accessing the deployed services URL in your browser: [https://portal.ingress.local/service-demo](https://portal.ingress.local/service-demo)

The demo service should be accessible and you should see a simple web page with a message indicating that the service is running.

### Create your own module

As EKM-Partner you request a new module from gematik. We will create a new module similar to the ekm-template, name the new module and its namespace and include it in our internal processes. Part of the new module is a folder in this project at root level, for generic deployment configuration of your services, and a folder with the same name in the [stage-public](https://github.com/gematik/DEMIS-stage-public) repository for the environment specific configuration.
As for all other deployment modules, there will be make targets to deploy and undeploy the new module.
You can use the new module as a base for your own services and will likely want to:
- set your own helm and docker repositories in the stage configuration (variables `helm_repository` and `docker_registry` in application-configuration.tfvars for your module, e.g. for ekm-template: [application-configuration.tfvars](../environments/stage-public/ekm-template/application-configuration.tfvars) )
- set credentials for your helm and docker repositories (fill the variables in credentials.tfvars for your module, e.g. for ekm-template: [credentials.tfvars](../environments/stage-public/ekm-template/credentials.tfvars))
- add your own services in the new module and remove the service-demo
  - generic configuration of your service is done in this project
  - stage specific configuration is done in your environment under [environments](../environments)
  - create your own istio-policies and other configuration for your services:
    
    In the demo-module are the demis internal policies deployed. You need to create your own policy chart and use it instead of the demis policies.

If your services need to communicate with services in other namespaces (idm, demis, etc.) you need to request the necessary changes as pull-request or ticket to the gematik repository for [istio-policies](https://github.com/gematik/DEMIS-istio-policies) .


## Security Policy
If you want to see the security policy, please check our [SECURITY.md](SECURITY.md).

## Contributing
If you want to contribute, please check our [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Copyright 2024-2025 gematik GmbH

EUROPEAN UNION PUBLIC LICENCE v. 1.2

EUPL © the European Union 2007, 2016

See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License

## Additional Notes and Disclaimer from gematik GmbH

1. Copyright notice: Each published work result is accompanied by an explicit statement of the license conditions for use. These are regularly typical conditions in connection with open source or free software. Programs described/provided/linked here are free software, unless otherwise stated.
2. Permission notice: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    1. The copyright notice (Item 1) and the permission notice (Item 2) shall be included in all copies or substantial portions of the Software.
    2. The software is provided "as is" without warranty of any kind, either express or implied, including, but not limited to, the warranties of fitness for a particular purpose, merchantability, and/or non-infringement. The authors or copyright holders shall not be liable in any manner whatsoever for any damages or other claims arising from, out of or in connection with the software or the use or other dealings with the software, whether in an action of contract, tort, or otherwise.
    3. We take open source license compliance very seriously. We are always striving to achieve compliance at all times and to improve our processes. If you find any issues or have any suggestions or comments, or if you see any other ways in which we can improve, please reach out to: ospo@gematik.de
3. Please note: Parts of this code may have been generated using AI-supported technology. Please take this into account, especially when troubleshooting, for security analyses and possible adjustments.

## Contact
E-Mail to [DEMIS Entwicklung](mailto:demis-entwicklung@gematik.de?subject=[GitHub]%20DEMIS-Development-Cluster)