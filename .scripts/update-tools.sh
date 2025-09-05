#!/usr/bin/env bash

set -euo pipefail

update_helm_ref() {
  if [ -f "${1}" ] && [[ "$(cat "${1}")" =~ baltocdn.com ]]; then
  sudo rm "${1}"
  echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  fi
}

update_helm_ref /etc/apt/sources.list.d/helm.list
update_helm_ref /etc/apt/sources.list.d/helm-stable-debian.list

echo "##### Updating Packages"
sudo apt-get update
sudo apt-get dist-upgrade -y
  
echo "##### Updating yq"
curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o yq
chmod +x yq
sudo mv yq /usr/local/bin/yq
  
echo "##### Updating kind"
curl -fsSL https://github.com/kubernetes-sigs/kind/releases/latest/download/kind-linux-amd64 -o kind
chmod +x kind
sudo mv kind /usr/local/bin/kind

echo "##### Updating tflint"
curl -fsSL https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip -o tflint.zip
unzip tflint.zip 
chmod +x tflint
sudo mv tflint /usr/local/bin/tflint 
rm tflint.zip

echo "##### Updating checkov"
curl -fsSL https://github.com/bridgecrewio/checkov/releases/latest/download/checkov_linux_X86_64.zip -o checkov.zip
unzip -d checkov checkov.zip
chmod +x checkov/dist/checkov
sudo mv checkov/dist/checkov /usr/local/bin/checkov 
rm -rf checkov* 

echo "##### Updating terraform-docs"
curl -fsSL https://github.com/terraform-docs/terraform-docs/releases/download/v0.19.0/terraform-docs-v0.19.0-linux-amd64.tar.gz -o terraform-docs.tar.gz 
sudo tar -zxvf terraform-docs.tar.gz -C /usr/local/bin/ terraform-docs
sudo chmod +x /usr/local/bin/terraform-docs 
rm -f terraform-docs.tar.gz
