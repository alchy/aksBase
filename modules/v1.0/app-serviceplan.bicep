param hostingPlanName string
param sku string
param skuCode string
param workerSize string
param workerSizeId string
param numberOfWorkers string
param tags object = {
  tags: 'null tags'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: hostingPlanName
  location: resourceGroup().location
  kind: 'linux'
  properties: {
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    reserved: true
  }
  sku: {
    tier: sku
    name: skuCode
  }
  tags: tags
}

output id string = appServicePlan.id
