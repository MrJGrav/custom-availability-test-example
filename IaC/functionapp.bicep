param baseName string
param location string
param aspId string
param subnetId string
param webAppHostName string

var uniqueName = '${uniqueString(baseName, 'functionApp', resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: uniqueName
  location: location 
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource ai 'Microsoft.Insights/components@2015-05-01' = {
  name: baseName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource fa 'Microsoft.Web/sites@2019-08-01' = {
  name: uniqueName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: aspId
  }
  kind: 'functionapp'

  resource appSettings 'config@2018-11-01' = {
    name: 'appsettings'
    properties: {
      'AzureWebJobsStorage': 'DefaultEndpointsProtocol=https;AccountName=${stg.name};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', stg.name), '2015-05-01-preview').key1}'
      'FUNCTIONS_EXTENSION_VERSION': '~3'
      'FUNCTIONS_WORKER_RUNTIME': 'powershell'
      'FUNCTIONS_WORKER_RUNTIME_VERSION': '~7'
      'APPINSIGHTS_INSTRUMENTATIONKEY': ai.properties.InstrumentationKey
      'webAppHostname': webAppHostName
      'location': resourceGroup().location
    }
  }

  resource netConfig 'networkConfig@2020-10-01' = {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: subnetId
    }
  }
}

output functionAppName string = fa.name
output functionAppId string = fa.id
