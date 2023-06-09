param location string
param networkInterfaceName1 string
param enableAcceleratedNetworking bool
param subnetName string
param virtualNetworkId string
param publicIpAddressName1 string
param publicIpAddressType string
param publicIpAddressSku string
param pipDeleteOption string
param virtualMachineName string
param virtualMachineName1 string
param virtualMachineComputerName1 string
param virtualMachineRG string
param osDiskType string
param osDiskDeleteOption string
param dataDisks1 array
param dataDiskResources1 array
param virtualMachineSize string
param nicDeleteOption string
param adminUsername string

@secure()
param adminPassword string
param patchMode string
param enableHotpatching bool
param virtualMachine1Zone string
param sqlVirtualMachineLocation string
param sqlVirtualMachineName string
param sqlConnectivityType string
param sqlPortNumber int
param sqlStorageDisksCount int
param sqlStorageWorkloadType string
param sqlStorageDisksConfigurationType string
param sqlStorageStartingDeviceId int
param sqlStorageDeploymentToken int
param sqlAutopatchingDayOfWeek string
param sqlAutopatchingStartHour string
param sqlAutopatchingWindowDuration string
param sqlAuthenticationLogin string

@secure()
param sqlAuthenticationPassword string
param dataPath string
param dataDisksLUNs array
param logPath string
param logDisksLUNs array
param tempDbPath string
param dataFileCount int
param dataFileSize int
param dataGrowth int
param logFileSize int
param logGrowth int
param SQLSystemDbOnDataDisk bool
param rServicesEnabled string
param maxdop int
param isOptimizeForAdHocWorkloadsEnabled bool
param collation string
param minServerMemoryMB int
param maxServerMemoryMB int
param isLPIMEnabled bool
param isIFIEnabled bool

var vnetId = virtualNetworkId
var vnetName = last(split(vnetId, '/'))
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource networkInterface1 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: networkInterfaceName1
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName1)
            properties: {
              deleteOption: pipDeleteOption
            }
          }
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
  }
  dependsOn: [
    publicIpAddress1
  ]
}

resource publicIpAddress1 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: publicIpAddressName1
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
  sku: {
    name: publicIpAddressSku
  }
  zones: [
    virtualMachine1Zone
  ]
}

resource dataDiskResources1_name 'Microsoft.Compute/disks@2022-03-02' = [for item in dataDiskResources1: {
  name: item.name
  location: location
  properties: item.properties
  sku: {
    name: item.sku
  }
  zones: (contains(item.sku, '_ZRS') ? json('null') : array(virtualMachine1Zone))
}]

resource virtualMachine1 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtualMachineName1
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      imageReference: {
        publisher: 'microsoftsqlserver'
        offer: 'sql2019-ws2019'
        sku: 'standard'
        version: 'latest'
      }
      dataDisks: [for item in dataDisks1: {
        lun: item.lun
        createOption: item.createOption
        caching: item.caching
        diskSizeGB: item.diskSizeGB
        managedDisk: {
          id: (item.id ?? ((item.name == json('null')) ? json('null') : resourceId('Microsoft.Compute/disks', item.name)))
          storageAccountType: item.storageAccountType
        }
        deleteOption: item.deleteOption
        writeAcceleratorEnabled: item.writeAcceleratorEnabled
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface1.id
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineComputerName1
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: enableHotpatching
          patchMode: patchMode
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  zones: [
    virtualMachine1Zone
  ]
  dependsOn: [
    dataDiskResources1_name

  ]
}

resource sqlVirtualMachine 'Microsoft.SqlVirtualMachine/SqlVirtualMachines@2022-07-01-preview' = {
  name: sqlVirtualMachineName
  location: sqlVirtualMachineLocation
  properties: {
    virtualMachineResourceId: resourceId('Microsoft.Compute/virtualMachines', sqlVirtualMachineName)
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    leastPrivilegeMode: 'Enabled'
    autoPatchingSettings: {
      enable: true
      dayOfWeek: sqlAutopatchingDayOfWeek
      maintenanceWindowStartingHour: sqlAutopatchingStartHour
      maintenanceWindowDuration: sqlAutopatchingWindowDuration
    }
    keyVaultCredentialSettings: {
      enable: false
      credentialName: ''
    }
    storageConfigurationSettings: {
      diskConfigurationType: sqlStorageDisksConfigurationType
      storageWorkloadType: sqlStorageWorkloadType
      sqlDataSettings: {
        luns: dataDisksLUNs
        defaultFilePath: dataPath
      }
      sqlLogSettings: {
        luns: logDisksLUNs
        defaultFilePath: logPath
      }
      sqlTempDbSettings: {
        defaultFilePath: tempDbPath
        dataFileCount: dataFileCount
        dataFileSize: dataFileSize
        dataGrowth: dataGrowth
        logFileSize: logFileSize
        logGrowth: logGrowth
      }
      sqlSystemDbOnDataDisk: SQLSystemDbOnDataDisk
    }
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        connectivityType: sqlConnectivityType
        port: sqlPortNumber
        sqlAuthUpdateUserName: sqlAuthenticationLogin
        sqlAuthUpdatePassword: sqlAuthenticationPassword
      }
      additionalFeaturesServerConfigurations: {
        isRServicesEnabled: rServicesEnabled
      }
      sqlInstanceSettings: {
        maxDop: maxdop
        isOptimizeForAdHocWorkloadsEnabled: isOptimizeForAdHocWorkloadsEnabled
        collation: collation
        minServerMemoryMB: minServerMemoryMB
        maxServerMemoryMB: maxServerMemoryMB
        isLpimEnabled: isLPIMEnabled
        isIfiEnabled: isIFIEnabled
      }
    }
  }
  dependsOn: [
    resourceId('Microsoft.Compute/virtualMachines', sqlVirtualMachineName)
  ]
}

output adminUsername string = adminUsername