// Priradi pristupove prava k ACR pro AKS cluster
param acrName               string                                                // Název registru
param aksClusterName        string                                                // Objekt AKS clusteru
param aksResourceGroupName  string                                                // Název RG AKS


// Existing AkS cluster
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-09-02-preview' existing = {
  name: aksClusterName
  scope: resourceGroup(aksResourceGroupName)
}

// Existing ACR
resource acrExisting 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: acrName
}

// Assign the AcrPull role to the AKS managed identity - je použit existující ACR
resource roleAssignmentExisting 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acrExisting.id, aksCluster.name, 'AcrPull')
  scope: acrExisting
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role ID
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

// Výstupy                                                                       
// ID a název pro další použití
output acrId              string = acrExisting.id
output acrName            string = acrExisting.name
