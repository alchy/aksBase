// Definice node poolů pro AKS cluster                                           
// Iteruje nad definicí poolů z konfigurace
param subnetId            string                                               // ID subnetu, kde budou pooly nasazeny
param nodePools           array                                                // Pole objektů s konfigurací poolů

// Dynamická definice node poolů pomocí iterace                                 
// Vytvoří pooly podle konfigurace
var agentPoolProfiles = [for pool in nodePools: {
  name: pool.name                                                              // Název poolu z konfigurace
  count: pool.?count                                                           // Počet uzlů (null pokud není definován)
  minCount: pool.?minCount                                                     // Minimální počet (null pokud není definován)
  maxCount: pool.?maxCount                                                     // Maximální počet (null pokud není definován)
  enableAutoScaling: pool.?enableAutoScaling ?? false                          // Autoškálování (výchozí false)
  vmSize: pool.vmSize                                                          // Velikost VM
  osType: 'Linux'                                                              // Typ OS
  osSKU: 'AzureLinux'                                                          // Specifický OS
  mode: pool.mode                                                              // Režim (System/User)
  type: 'VirtualMachineScaleSets'                                              // Typ škálování
  maxPods: pool.maxPods                                                        // Maximální počet podů
  nodeLabels: pool.?nodeLabels ?? {}                                           // Štítky (prázdné, pokud nejsou)
  nodeTaints: pool.?nodeTaints ?? []                                           // Tainty (prázdné, pokud nejsou)
  vnetSubnetID: subnetId                                                       // ID subnetu
}]

// Výstup pole agentPoolProfiles
// Předá pooly do aks-cluster.bicep
output agentPoolProfiles  array = agentPoolProfiles                            // Výsledné pole "poolů"
