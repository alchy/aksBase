// Definice Azure Container Registry (ACR)                                       
// Vytvoří registr image kontejnerů
param location            string                                               // Lokalita registru
param tags                object                                               // Štítky
param acrName             string                                               // Název registru

// Vytvoření ACR                                                                 
resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName                                                                // Název registru
  location: location                                                           // Lokalita
  tags: tags                                                                   // Štítky
  sku: { name: 'Basic' }                                                       // Základní SKU
  identity: { type: 'SystemAssigned' }                                         // Systémem přiřazená identita
  properties: { adminUserEnabled: true }                                       // Povolení admin uživatele
}

// Výstupy                                                                       
// ID a název pro další použití
output acrId              string = acr.id                                     // ID registru
output acrName            string = acr.name                                   // Název registru
