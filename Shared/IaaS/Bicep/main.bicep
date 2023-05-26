// ----------
// Parameters
// ----------

// param config object = loadJsonContent('configs/main.json')
var config = loadJsonContent('configs/main.json')

// merged config variable that merges the main with the application/version config
var mergedConfig = union(loadJsonContent('defaults.json'), config)

var config2008 = union(loadJsonContent('configs/main.json'),
  { 
    initScript: loadTextContent('scripts/post-config-win2k8r2-sql.ps1')
    numberVms: 1
  })

var config2012= union(loadJsonContent('configs/main.json'),
{ 
  initScript: loadTextContent('scripts/config_default.ps1')
  numberVms: 1
})

var configDefault= union(loadJsonContent('configs/main.json'),
{ 
  initScript: loadTextContent('scripts/config_default.ps1')
})

var config2019 = union(loadJsonContent('configs/main.json'),
{ 
  initScript: loadTextContent('scripts/config_win2019.ps1')
})

param imagesRefs array = loadJsonContent('configs/imagerefs.json')

// ------
// Scopes
// ------

targetScope = 'subscription'

// -------
// Modules
// -------

module groups './modules/groups/resources.bicep' = {
  name: 'Microsoft.Resources.AppMigWorkshopGroups'
  scope: subscription()
  params: {
    config: mergedConfig
  }
}

// Apps from Israel's repo: Classifieds, TimeTracker, and Jobs
module components2008R2 './modules/components/IISVM.bicep' = [for number in range(1,config2008.numberVms): {
  name: 'Microsoft.Resources.VM2008${number}'
  scope: resourceGroup(config2008.resourceGroup)
  params: {
    config: config2008
    imageRef: imagesRefs[0]
    year: '2008'
    number: string(number)
  }
  dependsOn: [
    groups
  ]
}]

// ----------
// Outputs
// ----------

//we do not return or log the vm password since that was passed as a param
output appliedConfig object  = mergedConfig
// output storage object = storage
// output virtualmachines array = [for i in range(0, config.numberVms - 1): { 
//     i: components2008R2[i].outputs 
// }]
