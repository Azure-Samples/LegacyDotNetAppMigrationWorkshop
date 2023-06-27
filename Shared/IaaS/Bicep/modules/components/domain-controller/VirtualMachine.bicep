// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Variables
// ---------

var command = '$password = ConvertTo-SecureString ${config.vm.adminPassword} -AsPlainText -Force; Import-Module ADDSDeployment; Initialize-Disk -Number 1 -PartitionStyle MBR; New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter F; Format-Volume -DriveLetter F -FileSystem NTFS; Add-WindowsFeature -name ad-domain-services -IncludeManagementTools; Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName "appmigrationworkshop.com" -DatabasePath "F:\\\\NTDS" -LogPath "F:\\\\NTDS" -SYSVOLPath "F:\\\\SYSVOL" -DomainNetbiosName "appmigws" -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true; shutdown -r -t 10; exit 0'

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


resource domainDisk 'Microsoft.Compute/disks@2021-04-01' = {
  name: 'domainDisk'
  location: config.location
  sku: {
    name: 'StandardSSD_LRS'
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 128
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
        dataDisks: [
          {
            lun: 1
            createOption: 'Attach'
            managedDisk: {
              id: domainDisk.id
            }
          }
        ]
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

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: 'vmExtensionDomainController'
  location: config.location
  parent: vm
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -Command ${command}' 
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

