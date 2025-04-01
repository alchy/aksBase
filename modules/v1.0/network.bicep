param location string
param vnetName string
param vnetAddressPrefix string
param subnetName string
param subnetAddressPrefix string
param nsgRules array = []
param tags object


resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-${subnetName}'
  location: location
  tags: tags
  properties: {
    securityRules: nsgRules  // Apply initial rules (can be empty)
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: [ vnetAddressPrefix ] }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          // serviceEndpoints: umožňuje přímé připojení k službám Azure Key Vault a Azure Storage z této podsítě, aniž by provoz musel opustit síť Azure a procházet internetem
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
            }
            {
              service: 'Microsoft.Storage'
            }
          ]
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output subnetId string = vnet.properties.subnets[0].id
output nsgId string = nsg.id
output nsgName string = nsg.name
