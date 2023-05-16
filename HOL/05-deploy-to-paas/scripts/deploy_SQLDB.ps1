#
# Preferences
#

$ErrorActionPreference = "Stop" 

#
# Variables
#

Set-Variable -Name "resourceName" -Value ""
Set-Variable -Name "location" -Value "eastus"
Set-Variable -Name "sqlServerUsername" -Value "azureuser"
Set-Variable -Name "sqlServerPassword" -Value ""
Set-Variable -Name "sqlDatabaseName" -Value "IBuySpyv3"

#
# Import
#
try {    
    Write-Verbose -Message "=> Importing modules..." -Verbose    
    Import-Module -Name $("Az.Accounts", "Az.Resources", "Az.Sql")
}
catch {    
    Write-Warning -Message "Terminating script - Failed to import module dependencies `n!> $($_.Exception.Message)"    
    break
}

#
# Deployment
#

$parameters = @{    
    location          = $location   
    resourceName      = $resourceName    
    sqlServerUsername = $sqlServerUsername    
    sqlServerPassword = $sqlServerPassword
}
try {    
    Write-Verbose -Message "=> Creating resource group..." -Verbose    
    New-AzResourceGroup 
        -Name $resourceName
        -Location "eastus"  
        -Force | Out-Null    
    Write-Verbose -Message "=> Starting deployment..." -Verbose    
    New-AzResourceGroupDeployment   
        -Name "Microsoft.Deployment" 
        -ResourceGroupName $resourceName
        -TemplateFile "azuredeploy.json"
        -TemplateParameterObject $parameters
        -ErrorAction Stop | Out-Null
}
catch {    
    Write-Warning -Message "Terminating script - Failed to deploy resources `n!> $($_.Exception.Message)"   
    break
}

#
# Exists
#

Write-Verbose -Message "=> Checking database..." -Verbose
$databaseExists = Get-AzSqlDatabase
                -ServerName $resourceName
                -ResourceGroupName $resourceName
                -WarningAction SilentlyContinue |
                Where-Object -FilterScript { $_.DatabaseName -eq $sqlDatabaseName }
if ($databaseExists) {    
    Write-Warning -Message "Terminating script - Skipping database import"    
    break
}

#
# Import
#
try {    
    Write-Verbose -Message "=> Importing bacpac..." -Verbose    
    & 'C:\Program Files\Microsoft SQL Server\160\DAC\bin\SqlPackage.exe'
        /a:"import"
        /tcs:"Data Source=$resourceName.database.windows.net;Initial Catalog=$sqlDatabaseName;User Id=$sqlServerUsername;Password=$sqlServerPassword" 
        /sf:"C:\Deployment Scripts\$sqlDatabaseName.bacpac"
        /p:"DatabaseEdition=Standard" 
        /p:"DatabaseServiceObjective=S0"
}
catch {    
    Write-Warning -Message "Terminating script - Failed to import bacpac `n!> $($_.Exception.Message)"    
    break
}