#!/usr/bin/env bash
set -euo pipefail

function basic_tools() {
    echo "##### Installing basic tools"
    sudo apt-get update
    sudo apt-get install -y git make vim curl gpg wget jq unzip
}

function google_sdk() {
    # Install "Google Cloud SDK Sources" if not present
    if ls /etc/apt/sources.list.d/google-cloud-sdk.list 1> /dev/null 2>&1; then
        echo "##### Google Cloud SDK source list already exists."
    else
        echo "##### Installing Google Cloud SDK"
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        sudo apt-get install apt-transport-https ca-certificates gnupg bash-completion -y
        curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        if grep -q 'USE_GKE_GCLOUD_AUTH_PLUGIN' ~/.bashrc; then
            sed -i 's|^[ \t#]*\(USE_GKE_GCLOUD_AUTH_PLUGIN=\)\(.*\)|\1True|' ~/.bashrc
        else
            echo "USE_GKE_GCLOUD_AUTH_PLUGIN=True" >> ~/.bashrc
        fi  
    fi

    echo "##### Installing/Updating Google Cloud SDK"
    sudo apt-get update
    sudo apt-get install google-cloud-cli -y
    # Install "GKE auth plugin" if not present - required for GKE >= 1.25
    echo "##### Installing GKE auth plugin"
    sudo apt-get install google-cloud-cli-gke-gcloud-auth-plugin -y
      
    # Install "kubectl" if not present - directly use the Google Repository
    echo "##### Installing/Updating kubectl"
    sudo apt-get update
    sudo apt-get install kubectl -y
}

function terraform() {
    # Install "terraform" source if not present
    if ls /etc/apt/sources.list.d/terraform.list 1> /dev/null 2>&1; then
        echo "##### Terraform source list already exists."
    else
        echo "##### Installing terraform sources"
        echo "deb [signed-by=/usr/share/keyrings/terraform.gpg arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/terraform.list
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/terraform.gpg
    fi

    echo "##### Installing/Updating terraform"
    sudo apt-get update
    sudo apt-get install terraform -y
}

function tofu() {
    # Install "tofu" Source if not present
    if ls /etc/apt/sources.list.d/opentofu.list 1> /dev/null 2>&1; then
        echo "##### OpenTofu source list already exists."
    else 
        echo "##### Installing OpenTofu sources"
        sudo curl -fsSL https://get.opentofu.org/opentofu.gpg -o /etc/apt/trusted.gpg.d/opentofu.gpg && \
        curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/opentofu-repo.gpg && \
        echo "deb [signed-by=/etc/apt/trusted.gpg.d/opentofu.gpg,/etc/apt/trusted.gpg.d/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee -a /etc/apt/sources.list.d/opentofu.list
    fi

    echo "##### Installing/Updating OpenTofu"
    sudo apt-get update
    sudo apt-get install tofu -y
}

function helm()  {
    # Install "helm" source if not present
    if ls /etc/apt/sources.list.d/helm.list 1> /dev/null 2>&1; then
        echo "##### Helm source list already exists."
    else 
        echo "##### Installing helm sources"
        echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee -a /etc/apt/sources.list.d/helm.list
        curl -fsSL https://baltocdn.com/helm/signing.asc | sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg
    fi

    echo "##### Installing/Updating helm"
    sudo apt-get update
    sudo apt-get install helm -y
}

function advanced_tools() {
    echo "##### Installing yq"
    curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o yq
    chmod +x yq
    sudo mv yq /usr/local/bin/yq

    echo "##### Installing kind"
    curl -fsSL https://github.com/kubernetes-sigs/kind/releases/latest/download/kind-linux-amd64 -o kind
    chmod +x kind
    sudo mv kind /usr/local/bin/kind

    echo "##### Installing tflint"
    curl -fsSL https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip -o tflint.zip
    unzip tflint.zip
    chmod +x tflint
    sudo mv tflint /usr/local/bin/tflint
    rm tflint.zip

    echo "##### Installing checkov"
    curl -fsSL https://github.com/bridgecrewio/checkov/releases/latest/download/checkov_linux_X86_64.zip -o checkov.zip
    unzip -d checkov checkov.zip
    chmod +x checkov/dist/checkov
    sudo mv checkov/dist/checkov /usr/local/bin/checkov
    rm -rf checkov*

    echo "##### Installing terraform-docs"
    curl -fsSL https://github.com/terraform-docs/terraform-docs/releases/download/v0.19.0/terraform-docs-v0.19.0-linux-amd64.tar.gz -o terraform-docs.tar.gz
    sudo tar -zxvf terraform-docs.tar.gz -C /usr/local/bin/ terraform-docs
    sudo chmod +x /usr/local/bin/terraform-docs
    rm -f terraform-docs.tar.gz
}

function install_brew() {
    echo "##### Installing Brew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

function macos_install() {
    brew install git opentofu make yq jq helm wget curl vim kubectl kind tflint terraform-docs checkov
    brew install --cask google-cloud-sdk
    # Check if the line already exists to avoid duplicates
    if ! grep -q 'PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"' "$HOME/.zprofile"; then
        echo 'PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"' >> "$HOME/.zprofile"
        echo "Path added to .zprofile successfully."
    else
        echo "Path already exists in .zprofile."
    fi
}

# Detect OS
if [[ "$(uname)" == "Darwin" ]]; then
    macos_install
elif [[ "$(uname)" == "Linux" ]]; then
    basic_tools
    google_sdk
    terraform
    tofu
    helm
    advanced_tools
else
    # Other OS (Windows with WSL, FreeBSD, etc.)
    echo "Running on an unsupported OS: $(uname)"
    exit 1
fi
