// Definice virtuální sítě (VNet)                             
param location            string                                               // Lokalita pro VNet a subnet
param tags                object                                               // Štítky pro označení VNet
param vnetName            string                                               // Název virtuální sítě
param vnetAddressPrefix   string                                               // Rozsah adres pro VNet


// Vytvoření nebo aktualizace VNet bez specifikace subnetů
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: [ vnetAddressPrefix ] }
  }
}

// Výstupy                                                                       
output vnetId             string = vnet.id                                    // ID VNet
