targetScope = 'subscription'
param baseName string
param location string = deployment().location

resource rsg 'Microsoft.Resources/resourceGroups@2020-08-01' = {
  name: baseName
  location: location
  tags: {
    DestroyTime: '19:00'
  }
}

module asp 'asp.bicep' = {
  scope: rsg
  name: 'asp'
  params: {
    location: location
    name: baseName
  }
}

module vnet 'network.bicep' = {
  scope: rsg
  name: 'vnet'
  params: {
    basename: baseName
    location: location
  }
}

module functionApp 'functionapp.bicep' = {
  scope: rsg
  name: 'functionApp'
  params: {
    baseName: baseName
    location: location
    aspId: asp.outputs.aspId
    subnetId: vnet.outputs.functionAppSubnetId
    webAppHostName: webApp.outputs.appHostname
  }
}

module webApp 'webapp.bicep' = {
  scope: rsg
  name: 'webApp'
  params: {
    aspId: asp.outputs.aspId
    baseName: baseName
    location: location
  }
}

module webAppEndpoint 'private-endpoint.bicep' = {
  scope: rsg
  name: 'webAppEndpoint'
  params: {
    endpointName: 'pe-webapp'
    linkedServiceId: webApp.outputs.appId
    location: location
    privateDnsZoneId: vnet.outputs.privateDnsZoneId
    subnetId: vnet.outputs.webAppSubnetId
  }
}

output resourceGroupName string = rsg.name
output functionAppName string = functionApp.outputs.functionAppName
output webAppName string = webApp.outputs.appName
