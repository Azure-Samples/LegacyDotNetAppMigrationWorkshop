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

resource sqlUpdateCreds 'Microsoft.SqlVirtualMachine/SqlVirtualMachines@2022-07-01-preview' = {
  name: '${config.resources.vmName}${year}${number}'
  location: config.location
  properties: {
    virtualMachineResourceId: resourceId('Microsoft.Compute/virtualMachines', vm.name )
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        sqlAuthUpdateUserName: config.sqlAuthenticationLogin
        sqlAuthUpdatePassword: config.sqlAuthenticationPassword
      }
    }
  }
}

resource vmFEIISEnabled 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  name: 'vm-EnableIIS${year}${number}'
  location: config.location
  parent: vm
  properties: {
    asyncExecution: false
    runAsUser: config.vm.adminUsername
    runAsPassword:config.vm.adminPassword
    source: {
      script: config.initScript
    }
  }
}

resource vmJoindomain 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = {
  name: 'joinDomain'
  parent: vm
  location: config.location
  dependsOn: [
    vmFEIISEnabled
  ]
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: 'appmigrationworkshop.com'
      user: 'appmigws\\${config.vm.adminUsername}'
      restart: 'true'
      options: '3'
    }
    protectedSettings: {
      password: config.vm.adminPassword
    }
  }
}

// ----------
// Parameters
// ----------

param config object = loadJsonContent('../../../configs/main.json')
param year string
param imageRef object
param number string


// output
// output vmCreated object = {
//   name: vm.name
//   runCommandId: vmFEIISEnabled.id
// }

