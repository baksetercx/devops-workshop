#!/bin/bash

set -eo pipefail

create() {
    local resource_group_name="$1"
    local storage_account_name="$2"
    local container_name="$3"
    local location="$4"

    # Create resource group
    az group create \
        --name "$resource_group_name" \
        --location "$location"

    # Create storage account
    az storage account create \
        --resource-group "$resource_group_name" \
        --name "$storage_account_name" \
        --sku Standard_LRS \
        --encryption-services blob

    # Create blob container
    az storage container create \
        --name "$container_name" \
        --account-name "$storage_account_name"

    cat << EOF > terraform/providers.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name   = "$resource_group_name"
    storage_account_name  = "$storage_account_name"
    container_name        = "$container_name"
    key                   = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
EOF

}

delete() {
    local resource_group_name="$1"
    local storage_account_name="$2"
    local container_name="$3"

    # Remove the generated providers.tf file
    rm -f providers.tf

    # Delete blob container
    az storage container delete \
        --name "$container_name" \
        --account-name "$storage_account_name"

    # Delete storage account
    az storage account delete \
        --name "$storage_account_name" \
        --resource-group "$resource_group_name"

    # Delete resource group
    az group delete \
        --name "$resource_group_name" \
        --yes
}

main() {
    local resource_group_name='tfstate'
    local container_name='tfstate'
    local location='norwayeast'

    local storage_account_name
    storage_account_name="tfstate$RANDOM$RANDOM$RANDOM"

    if [[ "$1" == "create" ]]; then
        create "$resource_group_name" "$storage_account_name" "$container_name" "$location"
    elif [[ "$1" == "delete" ]]; then
        delete "$resource_group_name" "$storage_account_name" "$container_name"
    else
        echo "Usage: $0 [create|delete]"
        exit 1
    fi
}

main "$@"
