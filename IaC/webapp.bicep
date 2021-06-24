param location string
param baseName string
param aspId string

var uniqueName = '${uniqueString(baseName, 'webApp', resourceGroup().id)}'

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: uniqueName
  location: location
  properties: {
    serverFarmId: aspId
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: []
    }
  }
}

output appName string = appService.name
output appHostname string = appService.properties.defaultHostName
output appId string = appService.id
