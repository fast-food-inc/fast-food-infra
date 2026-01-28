#!/bin/bash
set -e

RESOURCE_GROUP_NAME="fast-food-tfstate-rg-v2"
STORAGE_ACCOUNT_NAME="tfstate$(date +%s)"
CONTAINER_NAME="tfstate"
LOCATION="centralus"

# Create Resource Group
echo "Creating Resource Group $RESOURCE_GROUP_NAME..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create Storage Account
echo "Creating Storage Account $STORAGE_ACCOUNT_NAME..."
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create Blob Container
echo "Creating Blob Container $CONTAINER_NAME..."
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

echo "✅ Storage Account Created"
echo "------------------------------------------------"
echo "Resource Group:       $RESOURCE_GROUP_NAME"
echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
echo "Container Name:       $CONTAINER_NAME"
echo "Key:                  terraform.tfstate"
echo "------------------------------------------------"
echo "Please update your provider.tf with these values."
