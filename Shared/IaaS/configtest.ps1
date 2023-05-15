param config object = loadJsonContent('../../configs/main.json')

az deployment sub create --location EastUS --template-file resources.bicep

