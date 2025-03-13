// Target scope: subscription
targetScope = 'subscription'

// Common parameters for all resources
param location string
param locationShort string
param environment string
param sequence string
param tags object

// Network parameters for AKS
param aksServiceCidr string
param aksDnsServiceIP string
param podCidrs array
param networkPluginMode string
param aksAuthorizedIPRanges array

// Parameters for node pools
param nodePools array

// Parameters for virtual network (VNet)
param aksVnetAddressPrefix string
param aksSubnetAddressPrefix string

// Naming module for resource naming pattern
module naming 'modules/v1.0/naming.bicep' = {
  name: 'naming-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupCommon
  params: {
    environment: environment
    locationShort: locationShort
    sequence: sequence
    nodePoolsArray: nodePools
  }
}

// Create resource group "common" at subscription scope
resource resourceGroupCommon 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-common-${environment}-${locationShort}'
  location: location
  tags: tags
}

// Create resource group for specific AKS cluster at subscription scope
resource resourceGroupAks 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-aks-${environment}-${locationShort}-${sequence}'
  location: location
  tags: tags
}

// Create VNet for AKS networks with module
module aksVnet 'modules/v1.0/vnet.bicep' = {
  name: 'vnetDeployment-aks-${environment}-${locationShort}'
  scope: resourceGroupCommon
  params: {
    location: location
    tags: tags
    vnetName: naming.outputs.aksVnetName
    vnetAddressPrefix: aksVnetAddressPrefix
  }
}

// Volání samostatného modulu pro přidání subnetu
module aksSubnet 'modules/v1.0/subnet.bicep' = {
  name: 'subnetDeployment-aks-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupCommon
  params: {
    vnetName: naming.outputs.aksVnetName
    subnetName: naming.outputs.aksSubnetName
    subnetAddressPrefix: aksSubnetAddressPrefix
  }
  dependsOn: [ aksVnet ]
}

// Create Log Analytics
module logAnalytics 'modules/v1.0/logAnalytics.bicep' = {
  name: 'logAnalyticsDeployment-aks-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAks
  params: {
    location: location
    tags: tags
    workspaceName: naming.outputs.logAnalyticsWorkspaceName
  }
}

// Create ACR
module acr 'modules/v1.0/acr.bicep' = {
  name: 'acrDeployment-aks-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAks
  params: {
    location: location
    tags: tags
    acrName: naming.outputs.acrName
  }
}

// Create Key Vault
module aksKeyVault 'modules/v1.0/keyvault.bicep' = {
  name: 'aksKeyVaultDeployment-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAks
  params: {
    location: location
    tags: tags
    keyVaultName: naming.outputs.aksKeyVaultName
  }
}

// Create AKS cluster
module aks 'modules/v1.0/aks-cluster.bicep' = {
  name: 'aksDeployment-aks-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAks
  params: {
    location: location
    tags: tags
    clusterName: naming.outputs.aksClusterName
    nodeResourceGroup: naming.outputs.aksNodeResourceGroup
    subnetId: aksSubnet.outputs.subnetId
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    acrId: acr.outputs.acrId
    serviceCidr: aksServiceCidr
    podCidrs: podCidrs
    dnsServiceIP: aksDnsServiceIP
    networkPluginMode: networkPluginMode
    nodePoolsArray: nodePools
    aksAuthorizedIPRanges: aksAuthorizedIPRanges
  }
  dependsOn: [ aksKeyVault ]
}

// Assign KeyValut with CSI driver to AKS
module assignKeyvalut 'modules/v1.0/keyvault-access.bicep' = {
  name: 'aksKeyVaultAccess-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAks
  params: {
    clusterName: naming.outputs.aksClusterName
    keyVaultName: aksKeyVault.outputs.keyVaultName
    nodeResourceGroup: naming.outputs.aksNodeResourceGroup
  }
  dependsOn: [ aks ]
}

// Outputs
output aksClusterName string = aks.outputs.aksClusterName
output aksControlPlaneFQDN string = aks.outputs.aksControlPlaneFQDN
output acrName string = acr.outputs.acrName
output aksVnetId string = aksVnet.outputs.vnetId
output aksSubnetId string = aksSubnet.outputs.subnetId
output aksKeyVaultName string = aksKeyVault.outputs.keyVaultName
output resourceGroupCommonName string = resourceGroupAks.name
output resourceGroupAksName string = resourceGroupCommon.name
output aksNodeResourceGroup string = naming.outputs.aksNodeResourceGroup
