// Definice Azure Key Vault - vytvoří Key Vault pro AKS nebo odkazuje na existující

param location string                                                                             // Lokalita Key Vault
param tags object                                                                                 // Štítky
param keyVaultName string                                                                         // Název Key Vault (např. kv-aks-lab-we-001)
param useExistingKeyVault bool                                                                    // Určuje, zda použít existující Key Vault
param vnetResourceGroupName string                                                                // Název resource group, kde je umístěna virtuální síť
param vnetName string                                                                             // Název virtuální sítě
param subnetName string                                                                           // Název podsítě, ze které bude povolen přístup

// Načtení existující virtuální sítě (VNet), pokud je zadána
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = if (!empty(vnetResourceGroupName) && !empty(vnetName)) {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
}

// Načtení existující podsítě, pokud je zadána
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = if (!empty(subnetName)) {
  parent: vnet
  name: subnetName
}

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
    networkAcls: !empty(subnetName) ? {
      bypass: 'AzureServices'                                                                   // Povolí přístup Azure službám přes jejich interní mechanismy
      defaultAction: 'Deny'                                                                     
      ipRules: []                                                                               // Žádné IP pravidla                       
      virtualNetworkRules: [                                                                    // Povoluje přístup pouze z podsítě uvedené v subnet.id
        {
          id: subnet.id
          ignoreMissingVnetServiceEndpoint: true                                                // zajišťuje, že přístup z podsítě bude povolen i v případě, že podsíť nemá aktivovaný service endpoint pro Key Vault
        }
      ]
    } : {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

// Odkaz na existující Key Vault (pokud je useExistingKeyVault nastaveno na true)
resource existingKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (useExistingKeyVault) {
  name: keyVaultName
}

// Výstup
output keyVaultName string = useExistingKeyVault ? existingKeyVault.name : keyVault.name
output keyVaultId string = useExistingKeyVault ? existingKeyVault.id : keyVault.id
