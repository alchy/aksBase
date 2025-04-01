// Modul pro centralizované pojmenování zdrojů - generuje názvy podle vzoru

// staticke parametry
var specid = 'vzp'                                                                                    // Unikatni identifikator pro Key Vault

// Zakladni parametry (prostredi, lokalita, poradove cislo)
param environment         string                                                                      // Prostředí (např. 'lab')
param locationShort       string                                                                      // Zkratka lokality (např. 'we')
param sequence            string                                                                      // Pořadové číslo zdroje (např. '001')

// Nazvy spolecnych zdrojů pres subscription
var commonKevValutName          = 'kv-${specid}-${environment}-${locationShort}-infra'                      // Spolecny Subcription Key Vault (např. kv-vzp-lab-infra) - bez pořadového čísla

// Nazvy zdroju pro konkretni cluster
var aksResourceGroupName  = 'rg-aks-controller-${environment}-${locationShort}-${sequence}'           // Skupina zdrojů (např. rg-aks-controller-lab-we-001)
var aksNodeResourceGroup  = 'rg-aks-nodes-${environment}-${locationShort}-${sequence}'                // Skupina pro VM (např. rg-akn-lab-we-001)
var aksVnetName           = 'vnet-aks-${environment}-${locationShort}-${sequence}'                    // Název VNet (např. vnet-aks-lab-we-001) per AKS
var aksSubnetName         = 'sn-aks-${environment}-${locationShort}-${sequence}'                      // Název subnetu (např. sn-aks-lab-we-001)
var aksClusterName        = 'aks-${environment}-${locationShort}-${sequence}'                         // Název clusteru (např. aks-lab-we-001)
var acrName               = 'acr${specid}${environment}${locationShort}${sequence}'                   // Název ACR (např. acrlabwe001) ! no dashes allowed !
var logAnalyticsWorkspaceName = 'la-aks-${environment}-${locationShort}-${sequence}'                  // Název Log Analytics (např. la-aks-lab-we-001)
var aksKeyVaultName       = 'kv-aks-${specid}-${environment}-${locationShort}-${sequence}'            // Název Key Vault pro AKS (např. kv-vzp-aks-lab-we-001)

// Pojmenovani nodepoolu pro konkretni cluster
//param nodePoolsArray array                                                                            // Pole objektu s definicemi nodepoolu
//var systemNodePoolNames = [for pool in nodePoolsArray: 'npsys${environment}${locationShort}${sequence}${pool.name}']
//var userNodePoolNames = [for pool in nodePoolsArray: 'npusr${environment}${locationShort}${sequence}${pool.name}']

// Výstupy pro použití v jiných modulech - předá názvy dál
output aksResourceGroupName       string = aksResourceGroupName                                       // Název resource group AKS
output aksNodeResourceGroup       string = aksNodeResourceGroup                                       // Název resource group AKS nodu
output aksClusterName             string = aksClusterName                                             // Název clusteru
output aksVnetName                string = aksVnetName                                                // Název VNet
output aksSubnetName              string = aksSubnetName                                              // Název subnetu
output acrName                    string = acrName                                                    // Název ACR
output logAnalyticsWorkspaceName  string = logAnalyticsWorkspaceName                                  // Název Log Analytics
output aksKeyVaultName            string = aksKeyVaultName                                            // Název Key Vault AKS
output commonKeyVaultName         string = commonKevValutName                                         // Název Key Vault infra (spolecny pro subskripci)
//output systemNodePoolNames        array = systemNodePoolNames                                         // Názvy nodepoolů
//output userNodePoolNames          array = userNodePoolNames                                           // Názvy nodepoolů
