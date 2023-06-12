// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------


resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${config.vm.publicIpName}bastion'
  location: config.location
  sku: {
    name: config.vm.publicIpSku
  }
  properties: {
    publicIPAllocationMethod: config.vm.publicIPAllocationMethod
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${config.vm.nicName}bastion'
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

resource bastionvm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: 'amwbastion'
  location: config.location
  tags: config.tags
  properties: {
    hardwareProfile: {
      vmSize: config.vm.vmSize
    }
    osProfile: {
      computerName: 'amwbastion'
      adminUsername: config.vm.adminUsername
      adminPassword: config.vm.adminPassword
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

resource vmapps 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  name: 'vm-bastionapps'
  location: config.location
  parent: bastionvm
  properties: {
    asyncExecution: false
    source: {
      script: config.initScript
    }
  }
}

// ----------
// Parameters
// ----------

param config object = loadJsonContent('../../configs/main.json')
param imageRef object


