// Definice Azure Container Registry (ACR)                                       
// Vytvoří registr image kontejnerů nebo použije existující na základě parametru

param location            string                                               // Lokalita registru (použito při vytváření nového)
param tags                object                                               // Štítky (použito při vytváření nového)
param acrName             string                                               // Název registru
param useExistingACR      bool                                                 // Určuje, zda použít existující ACR (true) nebo vytvořit nový (false)

// Použití existujícího ACR, pokud useExistingACR je true
resource acrExisting 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = if (useExistingACR) {
  name: acrName
}

// Vytvoření nového ACR, pokud useExistingACR je false
resource acrNew 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = if (!useExistingACR) {
  name: acrName
  location: location
  tags: tags
  sku: { name: 'Basic' }
  identity: { type: 'SystemAssigned' }
  properties: { adminUserEnabled: true }
}

// Výstupy                                                                       
// ID a název pro další použití
output acrId              string = useExistingACR ? acrExisting.id : acrNew.id
output acrName            string = useExistingACR ? acrExisting.name : acrNew.name
