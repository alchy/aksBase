param clusterName string
param poolName string
param subnetId string
param count int
param enableAutoScaling bool
param minCount int
param maxCount int
param vmSize string
param osType string
param osSKU string
param mode string
param type string
param maxPods int
param nodeLabels object
param nodeTaints array
param tags object = {
  tags: 'null tags'
}

resource aksAgentPool 'Microsoft.ContainerService/managedClusters/agentPools@2022-07-01' = {
  name: '${clusterName}/${poolName}'
  properties: {
    count: enableAutoScaling ? minCount : count
    enableAutoScaling: enableAutoScaling
    minCount: enableAutoScaling ? minCount : null
    maxCount: enableAutoScaling ? maxCount : null
    vmSize: vmSize
    osType: osType
    osSKU: osSKU
    mode: mode
    type: type
    maxPods: maxPods
    nodeLabels: nodeLabels
    nodeTaints: nodeTaints
    vnetSubnetID: subnetId
    osDiskSizeGB: 128
    availabilityZones: null
    enableNodePublicIP: false
    tags: tags
  }
}
