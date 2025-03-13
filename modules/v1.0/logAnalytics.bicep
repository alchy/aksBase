// Definice Log Analytics Workspace pro monitorování AKS                         
// Vytvoří pracovní prostor
param location            string                                               // Lokalita pracovního prostoru
param tags                object                                               // Štítky
param workspaceName       string                                               // Název pracovního prostoru

// Vytvoření Log Analytics Workspace                                             
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: workspaceName                                                          // Název pracovního prostoru
  location: location                                                           // Lokalita
  tags: tags                                                                   // Štítky
  properties: { sku: { name: 'PerGB2018' } }                                   // SKU pro placení za GB
}

// Výstup                                                                        
// ID pro další použití
output workspaceId        string = logAnalyticsWorkspace.id                     // ID pracovního prostoru
