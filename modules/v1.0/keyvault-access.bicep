param keyVaultName string
param nodeResourceGroup string
param clusterName string

// Reference the Key Vault in the main resource group
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName
}

// Compute the resource ID of the managed identity in the node resource group
var managedIdentityResourceId = resourceId(nodeResourceGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', 'azurekeyvaultsecretsprovider-${clusterName}')

// Retrieve the object ID of the managed identity
var managedIdentityObjectId = reference(managedIdentityResourceId, '2023-01-31').principalId

// Add access policy to the Key Vault
resource keyVaultAccessPoliciesCsi 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        objectId: managedIdentityObjectId
        permissions: {
          keys: ['get']
          secrets: ['get']
          certificates: ['get']
        }
        tenantId: tenant().tenantId
      }
    ]
  }
}
