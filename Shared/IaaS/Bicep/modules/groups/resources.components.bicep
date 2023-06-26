
// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

resource vn 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: config.resources.virtualNetworkName
  location: config.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        config.vnet.addressPrefix
      ]
    }
    subnets: [
      {
        name: config.vnet.subnetName
        properties: {
          addressPrefix: config.vnet.subnetPrefix
          networkSecurityGroup: {
            id: securityGroup.id
          }
        }
      }
    ]
  }
}

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: config.vnet.networkSecurityGroupName
  location: config.location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: config.ipAddressforRDP
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}


// ----------
// Parameters
// ----------

param config object

