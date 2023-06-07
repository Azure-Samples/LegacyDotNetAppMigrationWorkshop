function DownloadAndExpand
{
    param
    (
        [string]$AppName
    )

    Invoke-WebRequest "https://github.com/AppServiceMigrations/ApplicationSamples/raw/main/eShopMod.zip" -OutFile "$AppName.zip"
    Expand-Archive -Path "$AppName.zip" -DestinationPath "C:\Apps\$AppName"         
    Write-Output "Downloaded the $AppName web app" 
}
      
DownloadAndExpand -AppName "eShopMod"

Install-WindowsFeature -name Web-Server -IncludeManagementTools

Add-WindowsFeature Web-Asp-Net45

New-Item -ItemType Directory C:\LogMonitor; $downloads = @( @{ uri = 'https://github.com/microsoft/windows-container-tools/releases/download/v1.1/LogMonitor.exe'; outFile = 'C:\LogMonitor\LogMonitor.exe' }, @{ uri = 'https://raw.githubusercontent.com/microsoft/iis-docker/master/windowsservercore-insider/LogMonitorConfig.json'; outFile = 'C:\LogMonitor\LogMonitorConfig.json' } ); $downloads.ForEach({ Invoke-WebRequest -UseBasicParsing -Uri $psitem.uri -OutFile $psitem.outFile })

Remove-Item C:\inetpub\wwwroot\iisstart.*

xcopy C:\Apps\eShopMod\src\eShopModernizedMVC\* c:\inetpub\wwwroot /s

c:\windows\system32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /"[name='Default Web Site'].logFile.logTargetW3C:"File,ETW"" /commit:apphost

cd C:\Apps\$AppName\application
.\Startup.ps1