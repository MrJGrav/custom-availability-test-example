param name string
param location string

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: name
  location: location
  sku: {
    name: 'P1V2'
    capacity: 1
  }
  properties: {}
}

output aspId string = appServicePlan.id
