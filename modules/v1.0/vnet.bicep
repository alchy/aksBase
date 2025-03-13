// Definice virtuální sítě (VNet) a subnetu pro AKS                              
param location            string                                               // Lokalita pro VNet a subnet
param tags                object                                               // Štítky pro označení VNet
param vnetName            string                                               // Název virtuální sítě
param subnetName          string                                               // Název subnetu pro uzly AKS
param vnetAddressPrefix   string                                               // Rozsah adres pro VNet
param subnetAddressPrefix string                                               // Rozsah adres pro subnet

// Vytvoření VNet s integrovaným subnetem                                        
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName                                                              // Název VNet
  location: location                                                          // Lokalita
  tags: tags                                                                  // Štítky
  properties: {
    addressSpace: { addressPrefixes: [ vnetAddressPrefix ] }                  // Rozsah adres
    subnets: [                                                                // Definice subnetu
      {
        name: subnetName                                                       // Název subnetu
        properties: { addressPrefix: subnetAddressPrefix }                     // Rozsah adres subnetu
      }
    ]
  }
}

// Výstupy                                                                       
output subnetId           string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName) // ID subnetu
output vnetId             string = vnet.id                                    // ID VNet
