param basename string
param location string

var functionAppSubnetName = 'functionApp'
var webAppSubnetName = 'webApp'

resource vnet 'Microsoft.Network/virtualNetworks@2019-04-01' = {
  name: basename
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
    subnets: [
      {
        name: functionAppSubnetName
        properties: {
          addressPrefix: '10.0.0.0/26'
          delegations: [
            {
              name: 'Microsoft.Web/serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: webAppSubnetName
        properties: {
          addressPrefix: '10.0.0.64/26'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]    
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
  properties: {}

  resource link 'virtualNetworkLinks' = {
    name: '${vnet.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnet.id
      }
    } 
  }
}

output functionAppSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, functionAppSubnetName)
output webAppSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, webAppSubnetName)
output privateDnsZoneId string = privateDnsZone.id
