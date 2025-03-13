// Vytvoreni subnetu pro AKS     
param vnetName            string                                               // Název virtuální sítě do ktere se subnet vytváří
param subnetName          string                                               // Název subnetu pro uzly AKS
param subnetAddressPrefix string                                               // Rozsah adres pro subnet


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: '${vnetName}/${subnetName}'
  properties: {
    addressPrefix: subnetAddressPrefix
  }
}

// Výstupy
//output subnetId           string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName) // ID subnetu
output subnetId string = subnet.id                                                                     
