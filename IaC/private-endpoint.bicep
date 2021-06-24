param endpointName string
param location string
param subnetId string
param linkedServiceId string
param privateDnsZoneId string
param groupIds array = [
  'sites'
]

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: endpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'link1'
        properties: {
          privateLinkServiceId: linkedServiceId
          groupIds: groupIds
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${privateEndpoint.name}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
  
}
