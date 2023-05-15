// ------
// Scopes
// ------

targetScope = 'subscription'

// -------
// Modules
// -------

module main 'main.bicep' = {
  name: 'Microsoft.Resources.Main'
  params: {
    vmAdminPassword: vmAdminPassword
    config: config
  }
}
// ---------
// Variables
// ---------
var config = union(loadJsonContent('configs/main.json'), loadJsonContent('configs/main.win2k8-sql.json'),
  { 
    initScript: loadTextContent('scripts/post-config-win2k8r2-sql.ps1')
    location: location
    resourceGroup: resourceGroup
    createStorage: deployStorage
    numberVms: numberOfVms
    tags: tags
  })

// ----------
// Parameters
// ----------

@description('adminstrator password for vms')
@secure()
param vmAdminPassword string

@description('Azure region of the deployment')
param location string = 'centralus'

@description('Name of resource group to use, created if not exists')
param resourceGroup string 

@description('Whether a blob container should be created')
param deployStorage bool = true

@description('Whether a blob container should be created')
@minValue(1)
@maxValue(10)
param numberOfVms int = 1

@description('Tags applied to VMs.  Must be ane object of name:value(string) pairs')
param tags object = {}


// ----------
// Parameters
// ----------
output main object = main
