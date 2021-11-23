
# Set deployment environment variables
export subscriptionId='<Your Azure subscription ID>'
export appId='<Your Azure service principal name>'
export password='<Your Azure service principal password>'
export tenantId='<Your Azure tenant ID>'
export aksResourceGroup='<Resource Group Name>'
export location='<Resource Group Location>'
export aksClusterName='<AKS Cluster Name>'
export vnetName='<Virtual Network Name>'
export subnetName='<AKS Subnet Name>'

echo "Registering AKS Provider"
az provider register --namespace Microsoft.ContainerService --wait
az provider show -n Microsoft.ContainerService -o table

echo "Login to Az CLI using the service principal"
az login --service-principal --username $appId --password $password --tenant $tenantId

echo "Creating Resource Group"
az group create --name $aksResourceGroup --location $location

echo "Creating vNet"
az network vnet create \
    --resource-group $aksResourceGroup \
    --name $vnetName \
    --address-prefixes 192.168.0.0/16 \
    --subnet-name $subnetName \
    --subnet-prefix 192.168.1.0/24

echo "Get AKS Subnet"
subnetid=$(az network vnet subnet show --resource-group $aksResourceGroup --vnet-name $vnetName --name $subnetName --query id -o tsv)

echo "Create AKS Cluster"
az aks create \
    --resource-group $aksResourceGroup \
    --name $aksClusterName  \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --network-plugin azure \
    --vnet-subnet-id $subnetid \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.2.0.10 \
    --service-cidr 10.2.0.0/24 \
    --enable-managed-identity \
    --generate-ssh-keys
