// ----------
// Parameters
// ----------

// param config object = loadJsonContent('configs/main.json')
var config = loadJsonContent('configs/main.json')

var config2008 = union(loadJsonContent('configs/main.json'),
  { 
    initScript: loadTextContent('scripts/post-config-win2k8r2-sql.ps1')
    numberVms: 2
  })

var config2012= union(loadJsonContent('configs/main.json'),
{ 
  initScript: loadTextContent('scripts/config_default.ps1')
  numberVms: 2
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

// ----------
// Outputs
// ----------

//we do not return or log the vm password since that was passed as a param
output appliedConfig object  = mergedConfig
// output storage object = storage
// output virtualmachines array = [for i in range(0, config.numberVms - 1): { 
//     i: components2008R2[i].outputs 
// }]
