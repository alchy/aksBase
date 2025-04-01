// parametry predane z konfiguracniho souboru
param location string                                                         
param tags object                                                                           
param clusterName string                                                       
param nodeResourceGroup string                                                 
param subnetId string                                                          
param logAnalyticsWorkspaceId string                                           
param acrId string                                                             
param podCidrs array
param nodePoolsArray array
param aksAuthorizedIPRanges array
param dnsPrefix string = 'vzp'
param kubernetesVersion string                                                // https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli
param enableAppRouting bool
param networkPluginMode string

// defaultni hodnoty
param clusterSku object = {
  name: 'Base'
  tier: 'Standard'
}
param clusterIdentity object = {
  type: 'SystemAssigned'
}
param serviceCidr string = '172.18.224.0/20'                                  // Rozsah pro služby (internal CICR)
param dnsServiceIP string = '172.18.224.10'                                   // DNS adresa (within internal CIDR)
param isLocationEdgeZone bool = false
param edgeZone object = {}
param enableRBAC bool = true
param disableLocalAccounts bool = true
param enableAadProfile bool = true
param adminGroupObjectIDs array = [ 'f1f5d046-6eab-438b-90d7-b33e842075f3' ]  // eVZP_Azure-OTP
param azureRbac bool = true
param enablePrivateCluster bool = false
param isPrivateClusterSupported bool = true
param enableAuthorizedIpRange bool = true
param supportPlan string = 'KubernetesOfficial'
param isAzurePolicySupported bool = true
param enableAzurePolicy bool = true
param enableDiskEncryptionSetID bool = false
param diskEncryptionSetID string = ''
param loadBalancerSku string = 'Standard'
param networkPolicy string = 'azure'
param networkPlugin string = 'azure'
param networkDataplane string = 'azure'
param upgradeChannel string = 'none'
param nodeOSUpgradeChannel string = 'NodeImage'



var defaultAadProfile = {
  managed: true
  adminGroupObjectIDs: adminGroupObjectIDs
  enableAzureRBAC: azureRbac
}
var defaultApiServerAccessProfile = {
  authorizedIPRanges: (enableAuthorizedIpRange ? aksAuthorizedIPRanges : null)
  enablePrivateCluster: enablePrivateCluster
}
var defaultAzurePolicy = {
  enabled: enableAzurePolicy
}

var acrName = split(acrId, '/')[8]

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: acrName
}

module pools 'aks-nodepools.bicep' = {
  name: 'pools-${clusterName}'
  params: {
    subnetId: subnetId
    nodePools: nodePoolsArray
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-06-02-preview' = {
  name: clusterName
  location: location
  tags: tags
  identity: clusterIdentity
  sku: clusterSku
  extendedLocation: (isLocationEdgeZone ? edgeZone : null)
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsPrefix
    enableRBAC: enableRBAC
    disableLocalAccounts: disableLocalAccounts
    nodeResourceGroup: nodeResourceGroup
    aadProfile: (enableAadProfile ? defaultAadProfile : null)
    autoUpgradeProfile: {
      upgradeChannel: upgradeChannel
      nodeOSUpgradeChannel: nodeOSUpgradeChannel
    }
    agentPoolProfiles: pools.outputs.agentPoolProfiles
    apiServerAccessProfile: (isPrivateClusterSupported ? defaultApiServerAccessProfile : null)
    addonProfiles: union(
      {
        azureKeyvaultSecretsProvider: {
          enabled: true
          config: {
            enableSecretRotation: 'true'
            rotationPollInterval: '2m'
          }
        }
        omsAgent: {
          enabled: true
          config: {
            logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
          }
        }
        httpApplicationRouting: {
          enabled: enableAppRouting
        }
      },
      isAzurePolicySupported ? { azurepolicy: defaultAzurePolicy } : {}
    )
    diskEncryptionSetID: (enableDiskEncryptionSetID ? diskEncryptionSetID : null)
    supportPlan: supportPlan
    networkProfile: {
      loadBalancerSku: loadBalancerSku
      networkPlugin: networkPlugin
      networkPluginMode: networkPluginMode
      networkDataplane: networkDataplane
      networkPolicy: networkPolicy
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
      podCidrs: podCidrs
    }
  }
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(acrId, aksCluster.name, 'AcrPull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

output aksClusterName string = aksCluster.name
output aksControlPlaneFQDN string = aksCluster.properties.fqdn
