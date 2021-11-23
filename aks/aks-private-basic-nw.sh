#!/bin/bash

# Set deployment environment variables
export subscriptionId='<Your Azure subscription ID>'
export appId='<Your Azure service principal name>'
export password='<Your Azure service principal password>'
export tenantId='<Your Azure tenant ID>'
export aksResourceGroup='<Resource Group Name>'
export location='<Resource Group Location>'
export aksClusterName='<AKS Cluster Name>'

echo "Registering AKS Provider"
az provider register --namespace Microsoft.ContainerService --wait
az provider show -n Microsoft.ContainerService -o table

echo "Login to Az CLI using the service principal"
az login --service-principal --username $appId --password $password --tenant $tenantId

echo "Creating Resource Group"
az group create --name $aksResourceGroup --location $location

echo "Creating aks"
az aks create --name $aksResourceGroup --resource-group $aksResourceGroup --load-balancer-sku standard --enable-private-cluster --generate-ssh-keys