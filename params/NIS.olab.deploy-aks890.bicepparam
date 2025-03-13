// Konfigurační soubor AKS                                    
using '../deploy-aks.bicep'                                                   // Odkaz na provisoning soubor

// Konfigurace VNet s Subnet
param aksVnetAddressPrefix = '10.1.0.0/16'                                    // Rozsah VNet (vnet je spolecna pro vsechny clustery v subscription)
param aksSubnetAddressPrefix = '10.1.90.0/24'                                 // Subnet pro nody AKS (pro jednotlive clustery jine subnety)

// Společná konfigurace                                                          
param location            = 'westeurope'                                      // Celý název lokality
param locationShort       = 'we'                                              // Zkratka lokality
param environment         = 'olab'                                            // Prostředí 'lab/olab'
param sequence            = '890'                                             // Pořadové číslo, nebo nazev projektu
param tags                = {                                                 // Štítky
  environment: environment                                                    // Použije hodnotu prostředí
  id: sequence                                                                // Název projektu
}

// Síťové parametry pro AKS                                                   
param aksServiceCidr = '172.18.224.0/20'                                      // Rozsah pro služby (internal CICR)
param aksDnsServiceIP = '172.18.224.10'                                       // DNS adresa (within internal CIDR)
param podCidrs = [ '0.0.0.0/8' ]                                                  // Rozsah pro pody (https://en.wikipedia.org/wiki/Reserved_IP_addresses)
param networkPluginMode = 'overlay'                                           // Plugin mode
param aksAuthorizedIPRanges = [                                               // IP adresy ACL k API serveru
  '193.228.234.4'                                                             // VZP
  '193.228.234.11'                                                            // VZP
  '193.228.234.132'                                                           // VZP
  '4.223.99.163'                                                              // Release VM
  '13.93.122.175'                                                             // PoC Release VM
]

// Definice node poolů jako pole objektů                                         
param nodePools           = [                                                 // Pole poolů
  {                                                                           // Systémový pool
    name: 'systempool'                                                        // Název poolu (9 znaků, platný)
    count: 1                                                                  // Počet uzlů (minimum pro systém)
    vmSize: 'Standard_E2pds_v5'                                               // Velikost VM (2 vCPU, 16 GB RAM)
    mode: 'System'                                                            // Systémový pool
    maxPods: 30                                                               // Maximální počet podů
    nodeTaints: ['CriticalAddonsOnly=true:NoSchedule']                        // Taint pro systémové pody
  }
  {                                                                           // Uživatelský pool podle zadání
    name: 'labpool1'                                                          // Název poolu (8 znaků, platný)
    minCount: 1                                                               // Minimální počet uzlů
    maxCount: 2                                                               // Maximální počet uzlů
    enableAutoScaling: true                                                   // Autoškálování povoleno
    vmSize: 'Standard_E2pds_v5'                                               // Velikost VM (2 vCPU, 16 GB RAM)
    mode: 'User'                                                              // Uživatelský pool
    maxPods: 30                                                               // Maximální počet podů
  }
  {                                                                           // Uživatelský pool podle zadání
    name: 'maxipes1'                                                          // Název poolu (8 znaků, platný)
    minCount: 1                                                               // Minimální počet uzlů
    maxCount: 3                                                               // Maximální počet uzlů
    enableAutoScaling: true                                                   // Autoškálování povoleno
    vmSize: 'Standard_E2pds_v5'                                               // Velikost VM (2 vCPU, 16 GB RAM)
    mode: 'User'                                                              // Uživatelský pool
    maxPods: 30                                                               // Maximální počet podů
  }
]



