// Konfigurační soubor AKS                                    
using '../../../deploy-aks.bicep'                                              // Odkaz na provisoning soubor

/// 
/// Sekce zakladni konfigurace AKS:
///   - upravit "sequence"
///   - upravit "aksAddressPrefix" a "aksSubnetAddressPrefix"
///   - upravit "kubernetesVersion" (je-li pozadovana jina verze Kubernetes)
///   - upravit "enableAppRoutingBoolean" (pokud nebude pouzit nativni ingress controller)
///

// Pořadové číslo AKS
param sequence = '770'                                             
param workloadTags = {
  applicationName: 'moje 770 aks'
  ownerGroup: 'oddeleni odboje'
}

// Konfigurace VNet s Subnet
param aksVnetAddressPrefix = '10.1.70.0/24'                                   // Rozsah VNet (vnet je spolecna pro vsechny clustery v subscription)
param aksSubnetAddressPrefix = '10.1.70.0/24'                                 // Subnet pro nody AKS:
                                                                              //   - kazdy cluster ma svuj vnet + subnet
                                                                              //   - maska /24 (alokuj cely) nebo jen /25 (rezerva)

// Verze Kubernetes
param kubernetesVersion = '1.32.0'                                            // Verze Kubernetes: https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli

// Síťové parametry pro AKS                                                   
param podCidrs = [ '192.168.0.0/16' ]                                         // Rozsah pro pody (zmena pouze v pripade potreby, v rezimu 'overlay' je CIDR nepodstatny)
param networkPluginMode = 'overlay'                                           // Plugin mode
param aksAuthorizedIPRanges = [                                               // IP adresy ACL k API serveru
  '193.228.234.4'                                                             // VZP
  '193.228.234.11'                                                            // VZP
  '193.228.234.132'                                                           // VZP
  '4.223.99.163'                                                              // Release VM
  '13.93.122.175'                                                             // PoC Release VM
]

// Aplikacni routing
param enableAppRoutingBoolean = true                                          // Zapnutí httpApplicationRouting:
                                                                              //   - AKS automaticky nakonfiguruje ingress controller.
                                                                              //   - Vytvoří veřejnou IP adresu, přes kterou můžete přistupovat k aplikacím.
                                                                              //   - Nastaví DNS záznamy, díky čemuž jsou aplikace dostupné (např. moje-aplikace.<region>.aksapp.io).

/// 
/// Sekce konfigurace Nodu:
///   - upravit "nodePools"
///

// Systémový pool
param systemNodePools           = [                                                 
  {                                                                           
    name: 'systempool'                                                        
    mode: 'System'                                                            
    osType: 'Linux'                                                           
    osSKU: 'AzureLinux'  
    type: 'VirtualMachineScaleSets'              
    availabilityZones: null                                                            
    enableAutoScaling: false                                                                                                                          
    count: 1
    maxPods: 30                                                               
    vmSize: 'Standard_d2s_v3'                                                 
    nodeLabels: {}                                                            
    nodeTaints: ['CriticalAddonsOnly=true:NoSchedule']                        
  }
]

// User pools
param userNodePools = [
  {
    name: 'userpool1'  // Opravil jsem překlep z 'userpoo1'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    type: 'VirtualMachineScaleSets'
    availabilityZones: null
    enableAutoScaling: true
    count: 1
    maxPods: 100
    minCount: 1
    maxCount: 3
    nodeLabels: {}
    nodeTaints: []  // Přidána vlastnost nodeTaints
    vmSize: 'Standard_d2s_v3'
  }
  {
    name: 'userpool2'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    type: 'VirtualMachineScaleSets'
    availabilityZones: null
    enableAutoScaling: true
    count: 1
    maxPods: 100
    minCount: 1
    maxCount: 3
    nodeLabels: {}
    nodeTaints: []  // Přidána vlastnost nodeTaints
    vmSize: 'Standard_d2s_v3'
  }
]

///
/// Sekce ACL pro AKS Node vnet:
///   - v pripade potreby upravit "destinationAddressPrefix"
///
param nsgRules = [
  {
    name: 'Allow_VZP_Inbound'
    properties: {
      description: 'Allow VNet InBound communication to TCP 80 and 443'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRanges: [
        '443'
        '80'
      ]
      sourceAddressPrefixes: [
        '193.228.234.11'
        '193.228.234.4'
        '193.228.234.132'
        '46.23.52.120'
      ]
      destinationAddressPrefix: '*'  // Dočasně nastaveno na '*'. VZP IPs mohou pristupovat do podsite AKS
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
]

///
/// Sekce konfigurace na urovni subskripce:
///   - zustava pokud se nemeni "subskripce" nebo "location"
///

// Společná konfigurace prostredi
var env = loadJsonContent('../env.json')
param location  = env.location                                                // Celý název lokality
param locationShort = env.locationShort                                       // Zkratka lokality
param environment = env.environment                                           // Prostředí 'lab/olab'

//
// Sekce helper:
//   - objekty vyjmenovane v souboru se pri deploymentu ARM nepokusi vytvorit znovu
//   - soubor automaticky vytvari powershell helper (deploy-aks.ps1)
//
var recycle = loadJsonContent('./tmp/aks${sequence}-tmp.json')
param useExistingKeyVault = recycle.useExistingKeyVault
param useExistingACR = recycle.useExistingACR
