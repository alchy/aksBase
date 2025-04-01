param name string
param workspaceId string
param tags object = {
  tags: 'null tags'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: name
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Request_Source: 'IbizaWebAppExtensionCreate'
    Flow_Type: 'Redfield'
    Application_Type: 'web'
    WorkspaceResourceId: workspaceId
    DisableLocalAuth: false
  }
  tags: tags
}

output connectionString string = appInsights.properties.ConnectionString
