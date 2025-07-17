#####################
### General Settings
#####################

# Define the root directory
ROOT_DIR ?= $(shell pwd)

# Use Bash as default shell
SHELL := bash
# Set bash strict mode and enable warnings
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
# Making steps silent - don't print all the commands to stdout
.SILENT:

#####################
### Overridable Values
#####################
TF_BIN := tofu
INFRASTRUCTURE_PATH := infrastructure
APPLICATIONS_PATH := demis
APPLICATIONS_ENV_FOLDER := demis
IDM_PATH := idm
MESH_PATH := mesh
GCP_SECRET_PREFIX :=
TERRAFORM_EXTRA_ARGS :=
TARGET_ARG :=
MODULE :=
target :=

#####################
### Default Values
#####################
STAGE := public

# check if STAGE_REPOSITORY is empty and set accordingly
ifeq ($(strip $(STAGE_REPOSITORY)),)
    STAGE_REPOSITORY = git@github.com:gematik/DEMIS-stage-$(STAGE).git
endif

LOAD_EXTERNAL_SECRETS :=

# check if additional Makefile-Targets exists and include them
ifneq ($(wildcard $(ROOT_DIR)/deployments/local/local.mk),)
    include $(ROOT_DIR)/deployments/local/local.mk
endif
ifneq ($(wildcard $(ROOT_DIR)/deployments/secrets.mk),)
    include $(ROOT_DIR)/deployments/secrets.mk
endif

#####################
### Overridable Test Values
#####################
USE_LOCAL_WAF :=

#####################
### Makefile Targets
#####################

# .PHONY is required to use Makefile for bash commands without output file targets
.PHONY: help
help:
	@echo "### Available Targets"
	@echo ""
	@echo -e "Usage: make [\e[36mSELECTOR\e[0m] [\e[32mCOMMAND\e[0m]"
	@echo ""
	@echo "### Local Shortcuts:"
	@echo ""
	@echo "create-local-environment       		- Creates a complete local environment with KIND"
	@echo "cleanup-local-environment      		- Destroys the local environment"
	@echo "core-test-local                		- Runs the core tests for local cluster"
	@echo ""
	@echo -e "### \e[32mCommands\e[0m available:"
	@echo ""
	@echo "init-stage                     		- Pulls the latest changes from the stage repository"
	@echo "infrastructure                 		- Configures the infrastructure components"
	@echo "mesh                           		- Configures the mesh network components"
	@echo "idm                            		- Configures the identity management components"
	@echo "services                       		- Deploys DEMIS Services"
	@echo "update-service                 		- call this with image=<image> to update the service with the given image"
	@echo "update-istio-chart             		- call this with istio=[network-rules, policies-authorizations, policies-authentications] to upgrade the istio helm chart."
	@echo "cleanup-infrastructure         		- Removes the infrastructure components"
	@echo "cleanup-mesh         	      		- Removes the mesh network components"
	@echo "cleanup-idm         			  		- Removes the identity management components"
	@echo "cleanup-services               		- Removes the DEMIS Services"
	@echo "cleanup-services               		- Removes the DEMIS Services"
	@echo "get-backend-config-args-for-folder	- getting backend.tfvars file path as terraform backend-config argument"
	@echo "get-var-file-args-for-folder   		- getting all tfvars file paths as terraform arguments except backend.tfvars"
	@echo "docs                                 - updates README.md, after adjustments."
	@echo -e "### \e[36mSelectors\e[0m available:"
	@echo ""
	@echo "local                          		- Defines the Local environment"

.PHONY: infrastructure
infrastructure: export WORKING_PATH=$(ROOT_DIR)/$(INFRASTRUCTURE_PATH)
infrastructure: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(INFRASTRUCTURE_PATH) STAGE=$(STAGE))
infrastructure: init-infrastructure validate ## Creates the Kubernetes cluster
	echo "## Pre Downloading Grafana Dashboards"
	cd $(WORKING_PATH)/service-mesh/grafana/dashboards/
	sh ./downloader.sh
	cd $(WORKING_PATH)
	$(eval GLOUD_TOKEN=$(shell gcloud auth print-access-token))
	echo "## Checking for drifts"
	$(TF_BIN) plan -var=google_cloud_access_token=$(GLOUD_TOKEN) ${VAR_FILE_ARGS} -lock=false -refresh-only
	echo "## Computing Plan"
	$(TF_BIN) plan -var=google_cloud_access_token=$(GLOUD_TOKEN) ${VAR_FILE_ARGS} -out=tfplan.out
	echo "## Applying Plan"
	$(TF_BIN) apply -refresh-only $(TERRAFORM_EXTRA_ARGS) tfplan.out

init-infrastructure: export BACKEND_CONFIG_VARS=$(shell make -s --no-print-directory get-backend-config-args-for-folder MODULE=$(INFRASTRUCTURE_PATH) STAGE=$(STAGE))
init-infrastructure: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(INFRASTRUCTURE_PATH) STAGE=$(STAGE))
init-infrastructure: ## Initializes the Terraform infrastructure environment
	cd $(WORKING_PATH)
	@echo "## Initialising the infrastructure project"
	@echo "$(TF_BIN) init -reconfigure -upgrade ${VAR_FILE_ARGS} ${BACKEND_CONFIG_VARS}"
	$(TF_BIN) init -reconfigure -upgrade ${VAR_FILE_ARGS} ${BACKEND_CONFIG_VARS}
	@echo "## Initialising the infrastructure project done"

.PHONY: cleanup-infrastructure
cleanup-infrastructure: export WORKING_PATH=$(ROOT_DIR)/$(INFRASTRUCTURE_PATH)
cleanup-infrastructure: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(INFRASTRUCTURE_PATH) STAGE=$(STAGE))
cleanup-infrastructure: export BACKEND_CONFIG_VARS=$(shell make -s --no-print-directory get-backend-config-args-for-folder MODULE=$(INFRASTRUCTURE_PATH) STAGE=$(STAGE))
cleanup-infrastructure:
	cd $(WORKING_PATH)
	echo "## Destroying Infrastructure Resources"
	$(TF_BIN) init -reconfigure -upgrade ${VAR_FILE_ARGS} ${BACKEND_CONFIG_VARS}
	$(TF_BIN) destroy ${VAR_FILE_ARGS} $(TERRAFORM_EXTRA_ARGS)
	kubectl get crds | grep istio | awk '{print $1}' | xargs kubectl delete crd

.PHONY: idm
idm: export WORKING_PATH=$(ROOT_DIR)/$(IDM_PATH)
idm: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(IDM_PATH) STAGE=$(STAGE))
idm: init-idm validate ## Deploys the IDM components
	cd $(WORKING_PATH)
	$(eval GLOUD_TOKEN=$(shell gcloud auth print-access-token))
	echo "## Checking for drifts"
	$(TF_BIN) plan -var=google_cloud_access_token=$(GLOUD_TOKEN) ${VAR_FILE_ARGS} -lock=false -refresh-only
	echo "## Computing Plan"
	$(TF_BIN) plan -var=google_cloud_access_token=$(GLOUD_TOKEN) ${VAR_FILE_ARGS} -out=tfplan.out $(TARGET_ARG)
	echo "## Applying Plan"
	$(TF_BIN) apply $(TERRAFORM_EXTRA_ARGS) tfplan.out

.PHONY: cleanup-idm
cleanup-idm: export WORKING_PATH=$(ROOT_DIR)/$(IDM_PATH)
cleanup-idm: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(IDM_PATH) STAGE=$(STAGE))
cleanup-idm: export BACKEND_CONFIG_VARS=$(shell $(MAKE) -s get-backend-config-args-for-folder MODULE=$(IDM_PATH) STAGE=$(STAGE))
cleanup-idm:
	cd $(WORKING_PATH)
	$(eval GLOUD_TOKEN=$(shell gcloud auth print-access-token))
	echo "## Destroying IDM Resources"
	$(TF_BIN) init -reconfigure -upgrade ${VAR_FILE_ARGS} ${BACKEND_CONFIG_VARS}
	$(TF_BIN) destroy -var=google_cloud_access_token=$(GLOUD_TOKEN) ${VAR_FILE_ARGS} $(TERRAFORM_EXTRA_ARGS)

.PHONY: mesh
mesh: export WORKING_PATH=$(ROOT_DIR)/$(MESH_PATH)
mesh: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(MESH_PATH) STAGE=$(STAGE))
mesh: init-mesh validate ## Deploys DEMIS applications
ifneq ($(target),)
	$(eval TARGET_ARG="-target=$(target)")
endif
	cd $(WORKING_PATH)
	echo "## Checking for drifts"
	$(TF_BIN) plan ${VAR_FILE_ARGS} -lock=false -refresh-only
	echo "## Computing Plan"
	$(TF_BIN) plan ${VAR_FILE_ARGS} -out=tfplan.out $(TARGET_ARG)
	echo "## Applying Plan"
	$(TF_BIN) apply $(TERRAFORM_EXTRA_ARGS) tfplan.out

.PHONY: cleanup-mesh
cleanup-mesh: export WORKING_PATH=$(ROOT_DIR)/$(MESH_PATH)
cleanup-mesh: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(MESH_PATH) STAGE=$(STAGE))
cleanup-mesh: export BACKEND_CONFIG_VARS=$(shell make -s --no-print-directory get-backend-config-args-for-folder MODULE=$(MESH_PATH) STAGE=$(STAGE))
cleanup-mesh:
	cd $(WORKING_PATH)
	$(eval GLOUD_TOKEN=$(shell gcloud auth print-access-token))
	echo "## Destroying Mesh Resources"
	$(TF_BIN) init -reconfigure -upgrade ${VAR_FILE_ARGS} ${BACKEND_CONFIG_VARS}
	$(TF_BIN) destroy ${VAR_FILE_ARGS} $(TERRAFORM_EXTRA_ARGS)

.PHONY: demis
demis: services

.PHONY: services
services: export WORKING_PATH=$(ROOT_DIR)/$(APPLICATIONS_PATH)
services: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(APPLICATIONS_ENV_FOLDER) STAGE=$(STAGE))
services: init-services validate ## Deploys DEMIS applications
ifneq ($(target),)
	$(eval TARGET_ARG="-target=$(target)")
endif
	cd $(WORKING_PATH)
	$(eval GLOUD_TOKEN=$(shell gcloud auth print-access-token))
	echo "## Checking for drifts"
	$(TF_BIN) plan -var=google_cloud_access_token=$(GLOUD_TOKEN) ${VAR_FILE_ARGS} -lock=false -refresh-only $(TARGET_ARG)
	echo "## Computing Plan"
	$(TF_BIN) plan -var=google_cloud_access_token=$(GLOUD_TOKEN) ${VAR_FILE_ARGS} -out=tfplan.out $(TARGET_ARG)
	echo "## Applying Plan"
	$(TF_BIN) apply $(TERRAFORM_EXTRA_ARGS) tfplan.out

.PHONY: cleanup-services
cleanup-services: export WORKING_PATH=$(ROOT_DIR)/$(APPLICATIONS_PATH)
cleanup-services: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(APPLICATIONS_ENV_FOLDER) STAGE=$(STAGE))
cleanup-services: export BACKEND_CONFIG_VARS=$(shell make -s --no-print-directory get-backend-config-args-for-folder MODULE=$(APPLICATIONS_ENV_FOLDER) STAGE=$(STAGE))
cleanup-services:
	cd $(WORKING_PATH)
	$(eval GLOUD_TOKEN=$(shell gcloud auth print-access-token))
	echo "## Destroying DEMIS Resources"
	$(TF_BIN) init -reconfigure -upgrade ${VAR_FILE_ARGS} ${BACKEND_CONFIG_VARS}
	$(TF_BIN) destroy -var=google_cloud_access_token=$(GLOUD_TOKEN) ${VAR_FILE_ARGS} $(TERRAFORM_EXTRA_ARGS)

init-services: export BACKEND_CONFIG_VARS=$(shell make -s --no-print-directory get-backend-config-args-for-folder MODULE=$(APPLICATIONS_ENV_FOLDER) STAGE=$(STAGE))
init-services: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(APPLICATIONS_ENV_FOLDER) STAGE=$(STAGE))
init-services: ## Initializes the Terraform DEMIS Services
	cd $(WORKING_PATH)
	@echo "## Initialising the services project"
	$(TF_BIN) init -reconfigure -upgrade ${VAR_FILE_ARGS} ${BACKEND_CONFIG_VARS}

init-idm: export BACKEND_CONFIG_VARS=$(shell make -s --no-print-directory get-backend-config-args-for-folder MODULE=$(IDM_PATH) STAGE=$(STAGE))
init-idm: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(IDM_PATH) STAGE=$(STAGE))
init-idm: ## Initializes the Terraform IDM components
	cd $(WORKING_PATH)
	@echo "## Initialising the IDM project"
	$(TF_BIN) init -reconfigure -upgrade ${VAR_FILE_ARGS} ${BACKEND_CONFIG_VARS}

init-mesh: export BACKEND_CONFIG_VARS=$(shell make -s --no-print-directory get-backend-config-args-for-folder MODULE=$(MESH_PATH) STAGE=$(STAGE))
init-mesh: export VAR_FILE_ARGS=$(shell make -s --no-print-directory get-var-file-args-for-folder MODULE=$(MESH_PATH) STAGE=$(STAGE))
init-mesh: ## Initializes the Terraform Mesh components
	cd $(WORKING_PATH)
	@echo "## Initialising the Mesh project"
	@echo $(TF_BIN) init -reconfigure ${VAR_FILE_ARGS} -upgrade ${BACKEND_CONFIG_VARS}
	$(TF_BIN) init -reconfigure -upgrade ${VAR_FILE_ARGS} ${BACKEND_CONFIG_VARS}
	@echo "## Initialising the Mesh project done"

validate: ## Validates the configuration
	cd $(WORKING_PATH)
	@echo "## Performing Validation"
	$(TF_BIN) validate

.PHONY: local
local: ## Defines local resources
	@echo "Using STAGE=$(STAGE)"
	$(eval CURR_FOLDER=$(ROOT_DIR))
	$(eval GCP_SECRET_PREFIX=$(STAGE))
	$(eval TERRAFORM_EXTRA_ARGS=-auto-approve)
	@echo "## Cleaning up Backend Configuration"
	rm -rf $(CURR_FOLDER)/demis/backend.tf
	rm -rf $(CURR_FOLDER)/idm/backend.tf
	rm -rf $(CURR_FOLDER)/mesh/backend.tf
	rm -rf $(CURR_FOLDER)/infrastructure/backend.tf

.PHONY: init-stage
init-stage: export ENV_FOLDER=$(ROOT_DIR)/environments/stage-$(STAGE)
init-stage:
	@echo "## Initialising the stage repository"
	@echo "## Stage Folder: $(ENV_FOLDER)"
	@echo "## Stage: $(STAGE)"
	if [ -d "$(ENV_FOLDER)" ]; then \
		echo "Repository for $(STAGE) already present, try git pull" && \
		cd $(ENV_FOLDER) && \
		if git symbolic-ref --short -q HEAD > /dev/null; then \
			echo "## Pulling latest changes from $(STAGE_REPOSITORY)"; \
			git pull || exit 1; \
		else \
			echo "No branch checked out, skip git pull"; \
		fi \
	else \
		git clone $(STAGE_REPOSITORY) $(ENV_FOLDER) || exit 1; \
	fi
	$(LOAD_EXTERNAL_SECRETS)


.PHONY: create-local-environment
create-local-environment: local ## Creates a complete local environment
	$(MAKE) local infrastructure
	$(MAKE) local mesh
	$(MAKE) local idm
	$(MAKE) local services

.PHONY: cleanup-local-environment
cleanup-local-environment: ## Destroys the local environment
	$(MAKE) local cleanup-services
	$(MAKE) local cleanup-idm
	$(MAKE) local cleanup-mesh
	$(MAKE) local cleanup-infrastructure

.PHONY: update-service
update-service: export SCRIPT_FOLDER=$(ROOT_DIR)/.scripts
update-service:
	@if [[ -z "$(image)" || -z "$(namespace)" ]]; then \
		echo "Error: image and namespace parameter is required"; \
		echo "Usage: make update-service namespace=<namespace> image=<image>"; \
		exit 1; \
	fi
	$(SCRIPT_FOLDER)/update-service-local.sh -n $(namespace) $(image)

.PHONY: update-istio-chart
update-istio-chart: export SCRIPT_FOLDER=$(ROOT_DIR)/.scripts
update-istio-chart: ## call this target with istio=[network-rules,policies-authentications,policies-authorizations] namespace=[demis,idem,mesh] to update the istio helm chart locally
	$(SCRIPT_FOLDER)/update-istio-chart-local.sh $(istio) $(namespace)

.PHONY: reset-service
reset-service: export SCRIPT_FOLDER=$(ROOT_DIR)/.scripts
reset-service: ## call this target with service=<service-name> namespace=<namespace> to reset the service to the version from active-versions.yaml
	$(SCRIPT_FOLDER)/update-service-local.sh -r -n $(namespace) $(service)

.PHONY: update-service-helm
update-service-helm: export SCRIPT_FOLDER=$(ROOT_DIR)/.scripts
update-service-helm: ## call this target with image=<image> namespace=<namespace> to update the helm chart for this service
ifdef full
	$(SCRIPT_FOLDER)/update-service-local.sh -l -f -n $(namespace) $(image)
else
	$(SCRIPT_FOLDER)/update-service-local.sh -l -n $(namespace) $(image)
endif

.PHONY: update-canary-weight #call with Parameter CANARY_WEIGHT=100
update-canary-weight: export SCRIPT_FOLDER=$(ROOT_DIR)/.scripts
update-canary-weight: ### sets the weight for all canaries in active-versions.yaml
	$(SCRIPT_FOLDER)/canaryDeployment.sh update $(STAGE) all $(canary_weight)

.PHONY: update-canary-weight-100
update-canary-weight-100: export SCRIPT_FOLDER=$(ROOT_DIR)/.scripts
update-canary-weight-100:
	echo stage: "$(STAGE)"
	$(SCRIPT_FOLDER)/canaryDeployment.sh update $(STAGE) all 100

.PHONY: cleanup-canary-versions
cleanup-canary-versions: export SCRIPT_FOLDER=$(ROOT_DIR)/.scripts
cleanup-canary-versions: ## Removes all canary versions from the active-versions.yaml
	$(SCRIPT_FOLDER)/canaryDeployment.sh cleanup $(STAGE) all

.PHONY: core-test-local
core-test-local: export SCRIPT_FOLDER=$(ROOT_DIR)/.scripts
core-test-local: ## Runs the core tests for local cluster
	$(SCRIPT_FOLDER)/run-core-tests.sh --waf $(USE_LOCAL_WAF)

.PHONY: get-var-file-args-for-folder
get-var-file-args-for-folder:
ifneq ($(MODULE),)
	$(eval MODULE_PATH := "$(ROOT_DIR)/environments/stage-$(STAGE)/$(MODULE)")
	echo $(shell \
		if [ -d $(MODULE_PATH) ]; then \
	    	ls $(MODULE_PATH)/*.tfvars | grep -v backend.tfvars | xargs -I '§' echo "-var-file=§" | xargs echo -E; \
		else \
		    echo ""; \
		fi \
	)
else
	echo ""
endif

.PHONY: get-backend-config-args-for-folder
get-backend-config-args-for-folder:
ifneq ($(MODULE),)
	$(eval MODULE_PATH := "$(ROOT_DIR)/environments/stage-$(STAGE)/$(MODULE)")
	echo $(shell \
		if [ -f $(MODULE_PATH)/backend.tfvars ]; then \
	    	echo -backend-config=$(MODULE_PATH)/backend.tfvars; \
		else \
		    echo ""; \
		fi \
	)
else
	echo ""
endif

.PHONY: docs
docs: ## Generates documentation for all terraform modules
	@echo "## Generating documentation for all terraform modules"
	@for dir in $(shell find $(ROOT_DIR) -name '*.tf' -exec dirname {} \; | sort -u); do \
		terraform-docs -c "$(ROOT_DIR)/.tfdocs.yaml" "$$dir"; \
	done

.PHONY: lint
lint: ## Performs linting
	tflint --init
	tflint --recursive \
			--config="$(ROOT_DIR)/.tflint.hcl" \
			--minimum-failure-severity=warning

.PHONY: format
format: ## Autoformats the code
	@echo "## Autoformatting files"
	$(TF_BIN) fmt -recursive

.PHONY: check-changes
check-changes: ## Checks if there are any changes in repository
	git diff --exit-code

.PHONY: check-format
check-format: ## Checks if the code is formatted
	@echo "## Checking format"
	@$(TF_BIN) fmt -recursive -check -diff -write=false

.PHONY: checkov
checkov: ## Runs Checkov to check for security issues
	@echo "## Running Checkov"
	@checkov -d $(WORKING_PATH) --quiet --output cli --output junitxml --output-file console,$(WORKING_PATH)/checkov_report.xml

.PHONY: test-modules
test-modules: ## Runs tests for all modules
	@for dir in $(shell find $(ROOT_DIR) -name '*.tftest.hcl' -exec dirname {} \; | sort -u); do \
		printf "## Testing module: %s\n" "$$dir"; \
		cd "$$dir"; \
		tofu init 1> /dev/null; \
		tofu test -v 1> /dev/null; \
	done

.PHONY: chores
chores: ## Runs all chores
	@echo "## Running chores"
	@$(MAKE) format
	@$(MAKE) docs
	@$(MAKE) lint
	@$(MAKE) test-modules
	@$(MAKE) checkov WORKING_PATH=$(INFRASTRUCTURE_PATH)
	@$(MAKE) checkov WORKING_PATH=$(APPLICATIONS_PATH)
	@$(MAKE) checkov WORKING_PATH=$(IDM_PATH)
	@$(MAKE) checkov WORKING_PATH=$(MESH_PATH)