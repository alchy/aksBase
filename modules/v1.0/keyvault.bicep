// Definice Azure Key Vault                                                     
// Vytvoří Key Vault pro AKS nebo odkazuje na existující
param location string // Lokalita Key Vault
param tags object // Štítky
param keyVaultName string // Název Key Vault (např. kv-aks-lab-we-001)
@description('Indicates whether to use an existing Key Vault instead of creating a new one.')
param useExistingKeyVault bool = false // Nový parametr pro určení, zda použít existující Key Vault

// Vytvoření Key Vault (pokud není nastaveno useExistingKeyVault na true)
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = if (!useExistingKeyVault) {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enableRbacAuthorization: true
  }
}

// Odkaz na existující Key Vault (pokud je useExistingKeyVault nastaveno na true)
resource existingKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (useExistingKeyVault) {
  name: keyVaultName
}

// Výstup
// ID pro další použití
output keyVaultName string = keyVault.name
output keyVaultId string = useExistingKeyVault ? existingKeyVault.id : keyVault.id

