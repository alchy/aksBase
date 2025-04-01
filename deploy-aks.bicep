// Target scope: subscription
targetScope = 'subscription'

// Hlavní parametry pro nasazení 
param location string
param locationShort string
param environment string
param sequence string
param workloadTags object

// Docasne parametry pro nasazeni ktere se vytvareji podle aktualniho stavu prostredi
param useExistingKeyVault bool
param useExistingACR bool

// Network parameters for AKS
param podCidrs array
param networkPluginMode string
param aksAuthorizedIPRanges array
param enableAppRoutingBoolean bool
param kubernetesVersion string
param nsgRules array

// Parameters for node pools
param systemNodePools array
param userNodePools array

// Parameters for virtual network (VNet)
param aksVnetAddressPrefix string
param aksSubnetAddressPrefix string

// Sestavení univerzálního tagu
var globalTags = union({
  environment: environment
  location: location
  servicetype: 'aks'
  sequence: sequence
}, workloadTags)

// Create resource group "common" for common shared resources
resource resourceGroupCommon 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-common-${environment}-${locationShort}'                                                   // pozor, resourceGroupCommon se objevuje i v naming.bicep, ale
  location: location                                                                                  // v tomto pripade nemuze byt pojmenovani prejato z modulu
}

// Create resource group "network" (sequence number - per AKS cluster)
resource resourceGroupAksNetwork 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-aks-network-${environment}-${locationShort}-${sequence}'                                  // pozor, resourceGroupCommon se objevuje i v naming.bicep, ale
  location: location                                                                                  // v tomto pripade nemuze byt pojmenovani prejato z modulu
}

// Create RG for AKS cluster (sequence number - per AKS cluster)
resource resourceGroupAks 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-aks-controller-${environment}-${locationShort}-${sequence}'                               // pozor, resourceGroupAks se objevuje i v naming.bicep, ale 
  location: location                                                                                  // v tomto pripade nemuze byt pojmenovani prejato z modulu
  tags: globalTags
}

// Naming module for resource naming pattern
module naming 'modules/v1.0/naming.bicep' = {
  name: 'naming-${environment}-${locationShort}'
  scope: resourceGroupCommon
  params: {
    environment: environment
    locationShort: locationShort
    sequence: sequence
    //nodePoolsArray: nodePools
  }
}

/*
// Create VNet for AKS networks with module (sequence number - per AKS cluster)
module aksVnet 'modules/v1.0/vnet.bicep' = {
  name: 'aksVnet-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupInfra
  params: {
    location: location
    vnetName: naming.outputs.aksVnetName
    vnetAddressPrefix: aksVnetAddressPrefix
    tags: tags
  }
}

// Add subnet (sequence number - per AKS cluster)
module aksSubnet 'modules/v1.0/subnet.bicep' = {
  name: 'aksSubnet-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupInfra
  params: {
    vnetName: naming.outputs.aksVnetName
    subnetName: naming.outputs.aksSubnetName
    subnetAddressPrefix: aksSubnetAddressPrefix
  }
  dependsOn: [ aksVnet ]
}
*/

module aksNetwork 'modules/v1.0/network.bicep' = {
  name: 'aksNetwork-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAksNetwork
  params: {
    location: location
    tags: globalTags
    vnetName: naming.outputs.aksVnetName
    vnetAddressPrefix: aksVnetAddressPrefix
    subnetName: naming.outputs.aksSubnetName
    subnetAddressPrefix: aksSubnetAddressPrefix
    nsgRules: nsgRules
  }
}

// Create Log Analytics (sequence number - per AKS cluster)
module logAnalytics 'modules/v1.0/log-analytics.bicep' = {
  name: 'logAnalogAnalytics-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAks
  params: {
    location: location
    tags: globalTags
    workspaceName: naming.outputs.logAnalyticsWorkspaceName
  }
}

// Create ACR (sequence number - per AKS cluster)
module acr 'modules/v1.0/acr.bicep' = {
  name: 'acr-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAks
  params: {
    location: location
    tags: globalTags
    acrName: naming.outputs.acrName
    useExistingACR: useExistingACR
  }
}

// Create Key Vault (sequence number - per AKS cluster)
module aksKeyVault 'modules/v1.0/keyvault.bicep' = {
  name: 'aksKeyVault-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAks
  params: {
    location: location
    tags: globalTags
    keyVaultName: naming.outputs.aksKeyVaultName
    useExistingKeyVault: useExistingKeyVault
    vnetResourceGroupName: resourceGroupAksNetwork.name
    vnetName: naming.outputs.aksVnetName
    subnetName: naming.outputs.aksSubnetName
  }
  dependsOn: [ aksNetwork ]
}

// Create AKS cluster (sequence number - per AKS cluster)
module aks 'modules/v1.0/aks-cluster.bicep' = {
  name: 'aks-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAks
  params: {
    location: location
    tags: globalTags
    clusterName: naming.outputs.aksClusterName
    kubernetesVersion: kubernetesVersion
    nodeResourceGroup: naming.outputs.aksNodeResourceGroup                                  // v tomto pripade vytvari RG pro nody provisioning AKS, RG nesmi existovat drive
    subnetId: aksNetwork.outputs.subnetId
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    acrId: acr.outputs.acrId
    podCidrs: podCidrs
    networkPluginMode: networkPluginMode
    nodePoolsArray: systemNodePools
    aksAuthorizedIPRanges: aksAuthorizedIPRanges
    enableAppRouting: enableAppRoutingBoolean
    }
  dependsOn: [ aksKeyVault ]
}

// Assign KeyValut with CSI driver to AKS (sequence number - per AKS cluster)
module assignKeyvalut 'modules/v1.0/keyvault-access.bicep' = {
  name: 'assignKeyvalut-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAks
  params: {
    clusterName: naming.outputs.aksClusterName
    keyVaultName: naming.outputs.aksKeyVaultName
    nodeResourceGroup: naming.outputs.aksNodeResourceGroup
  }
  dependsOn: [ acr, aks ]
}

// Assign AKS permissions to access ACR (sequence number - per AKS cluster)
module acrAccess 'modules/v1.0/acr-access.bicep' = {
  name: 'acrAccess-${environment}-${locationShort}-${sequence}'
  scope: resourceGroupAks
  params: {
    aksClusterName: aks.outputs.aksClusterName
    aksResourceGroupName: resourceGroupAks.name
    acrName: naming.outputs.acrName 
  }
}

module aksAgentPools 'modules/v1.0/aks-agentpool.bicep' = [for pool in userNodePools: {
    name: 'aksAgentPool-${pool.name}-${environment}-${locationShort}-${sequence}'
    scope: resourceGroupAks
    params: {
      clusterName: aks.outputs.aksClusterName
      poolName: pool.name
      subnetId: aksNetwork.outputs.subnetId
      count: pool.count
      enableAutoScaling: pool.enableAutoScaling
      minCount: pool.minCount
      maxCount: pool.maxCount
      vmSize: pool.vmSize
      osType: pool.osType
      osSKU: pool.osSKU
      mode: pool.mode
      type: pool.type
      maxPods: pool.maxPods
      nodeLabels: pool.nodeLabels
      nodeTaints: pool.nodeTaints
      tags: globalTags
    }
  }
]


// Outputs
output aksClusterName string = aks.outputs.aksClusterName
output aksControlPlaneFQDN string = aks.outputs.aksControlPlaneFQDN
output acrName string = acr.outputs.acrName
output aksVnetId string = aksNetwork.outputs.vnetId
output aksSubnetId string = aksNetwork.outputs.subnetId
output aksKeyVaultName string = aksKeyVault.outputs.keyVaultName
output resourceGroupCommonName string = resourceGroupAks.name
output resourceGroupAksName string = resourceGroupAks.name
output aksNodeResourceGroup string = naming.outputs.aksNodeResourceGroup
