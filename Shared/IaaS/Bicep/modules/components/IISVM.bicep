// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------


resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${config.vm.publicIpName}${year}${number}'
  location: config.location
  sku: {
    name: config.vm.publicIpSku
  }
  properties: {
    publicIPAllocationMethod: config.vm.publicIPAllocationMethod
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${config.vm.nicName}${year}${number}'
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
  name: '${config.resources.vmName}${year}${number}'
  location: config.location
  tags: config.tags
  properties: {
    hardwareProfile: {
      vmSize: config.vm.vmSize
    }
    osProfile: {
      computerName: '${config.resources.vmName}${year}${number}'
      adminUsername: config.vm.adminUsername
      adminPassword: 'P@ssw0rd!@#ChangeM3'
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

resource vmFEIISEnabled 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  name: 'vm-EnableIIS${year}${number}'
  location: config.location
  parent: vm
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
param year string
param imageRef object
param number string

// output
// output vmCreated object = {
//   name: vm.name
//   runCommandId: vmFEIISEnabled.id
// }

