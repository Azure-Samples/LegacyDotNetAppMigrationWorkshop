// ------
// Scopes
// ------

targetScope = 'subscription'

// ---------
// Resources
// ---------

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: config.resourceGroup
  location: config.location
}

// ----------
// Parameters
// ----------

param config object
