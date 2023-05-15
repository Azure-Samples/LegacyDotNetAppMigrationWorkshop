// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------


resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${config.vm.publicIpName}${year}'
  location: config.location
  sku: {
    name: config.vm.publicIpSku
  }
  properties: {
    publicIPAllocationMethod: config.vm.publicIPAllocationMethod
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${config.vm.nicName}${year}'
  location: config.location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', config.resources.virtualNetworkName, config.vnet.subnetName)
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: '${config.resources.vmName}${year}'
  location: config.location
  tags: config.tags
  properties: {
    hardwareProfile: {
      vmSize: config.vm.vmSize
    }
    osProfile: {
      computerName: '${config.resources.vmName}${year}'
      adminUsername: config.vm.adminUsername
      adminPassword: 'n`^vNX,):XJ#4EsQ'
    }
    storageProfile: {
      imageReference: imageRef
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}


// ----------
// Parameters
// ----------

param config object = loadJsonContent('../../configs/main.json')
param year string
param imageRef object


