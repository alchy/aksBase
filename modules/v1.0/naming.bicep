// Modul pro centralizované pojmenování zdrojů - generuje názvy podle vzoru

// staticke parametry
var specid = 'vzp'                                                                                  // Unikatni identifikator pro Key Vault

// Zakladni parametry (prostredi, lokalita, poradove cislo)
param environment         string                                                                      // Prostředí (např. 'lab')
param locationShort       string                                                                      // Zkratka lokality (např. 'we')
param sequence            string                                                                      // Pořadové číslo zdroje (např. '001')

// Nazvy spolecnych zdrojů pres subscription
var aksVnetName           = 'vnet-aks-${environment}-${locationShort}'                                // Název VNet (např. vnet-aks-lab-we) - bez pořadového čísla, vnet je spolecny pro vsechny clustery v subscription
var kevValutName          = 'kv-${specid}-${environment}-${locationShort}-infra'                    // Spolecny Subcription Key Vault (např. kv-vzp-lab-infra) - bez pořadového čísla

// Nazvy zdroju pro konkretni cluster
var resourceGroupName     = 'rg-aks-${environment}-${locationShort}-${sequence}'                      // Skupina zdrojů (např. rg-aks-lab-we-001)
var aksNodeResourceGroup  = 'rg-aks-nodes-${environment}-${locationShort}-${sequence}'                // Skupina pro uzly (např. rg-aks-nodes-lab-we-001)
var aksSubnetName         = 'sn-aks-${environment}-${locationShort}-${sequence}'                      // Název subnetu (např. sn-aks-lab-we-001)
var aksClusterName        = 'aks-${environment}-${locationShort}-${sequence}'                         // Název clusteru (např. aks-lab-we-001)
var acrName               = 'acr${environment}${locationShort}${sequence}'                            // Název ACR (např. acrlabwe001) ! no dashes allowed !
var logAnalyticsWorkspaceName = 'la-aks-${environment}-${locationShort}-${sequence}'                  // Název Log Analytics (např. la-aks-lab-we-001)
var aksKeyVaultName       = 'kv-${specid}-${environment}-${locationShort}-aks-${sequence}'          // Název Key Vault (např. kv-aks-lab-we-001)

// Pojmenovani nodepoolu pro konkretni cluster
param nodePoolsArray array                                                                            // Pole objektu s definicemi nodepoolu
var nodePoolNames = [for pool in nodePoolsArray: 'np${environment}${locationShort}${sequence}${pool.name}']

// Výstupy pro použití v jiných modulech - předá názvy dál
output resourceGroupName  string = resourceGroupName                                                  // Název resource group
output aksClusterName     string = aksClusterName                                                     // Název clusteru
output aksNodeResourceGroup string = aksNodeResourceGroup                                             // Skupina pro uzly
output aksVnetName        string = aksVnetName                                                        // Název VNet
output aksSubnetName      string = aksSubnetName                                                      // Název subnetu
output acrName            string = acrName                                                            // Název ACR
output logAnalyticsWorkspaceName string = logAnalyticsWorkspaceName                                   // Název Log Analytics
output aksKeyVaultName    string = aksKeyVaultName                                                    // Název Key Vault AKS
output keyVaultName       string = kevValutName                                                       // Název Key Vault infra (spolecny pro subskripci)
output nodePoolNames      array = nodePoolNames
