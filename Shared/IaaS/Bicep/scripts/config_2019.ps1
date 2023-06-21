function DownloadAndExpand
{
    param
    (
        [string]$AppName
    )

    Invoke-WebRequest "https://github.com/ivegamsft/AppMigrationWorkshop/raw/master/Shared/SourceApps/Apps/$AppName.zip" -OutFile "$AppName.zip"
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$AppName.zip", "C:\Apps\$AppName")
    ((Get-Content -path C:\Apps\$AppName\web.config -Raw) -replace '<sqlServerName>.appmig.local',$env:computername) | Set-Content -Path C:\Apps\$AppName\web.config
   
    Write-Output "Downloaded the $AppName web app" 
}

function DownloadNewApps
{
    param
    (
        [string]$AppName
    )

    Invoke-WebRequest "https://raw.githubusercontent.com/rellismicrosoft/appmigrationtemp/main/$AppName.zip" -OutFile "$AppName.zip"
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$AppName.zip", "C:\Apps\$AppName")
    ((Get-Content -path C:\Apps\$AppName\web.config -Raw) -replace '<sqlServerName>.appmig.local',$env:computername) | Set-Content -Path C:\Apps\$AppName\web.config
   
    Write-Output "Downloaded the $AppName web app" 
}

#update the execution policy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force

#first update the tls level for this session, this is needed because 2012 defaults to TLS1.0
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Install IIS and ASP.NET 4.5
Install-WindowsFeature -name Web-Server -IncludeAllSubFeature

#install the .net 4.5 framework
Add-WindowsFeature Web-Asp-Net45

#add the compression assemblies to .net

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

#create user for the service account
net user AppsSvcAcct password1234! /ADD
c:\Windows\Microsoft.NET\Framework\v4.0.30319\aspnet_regiis.exe -ga ${env:computername}\AppsSvcAcct

#install databases
mkdir c:\Databases

SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "CREATE LOGIN [${env:computername}\AppsSvcAcct] FROM WINDOWS" > C:\Databases\db.log

Invoke-WebRequest "https://raw.githubusercontent.com/ivegamsft/AppMigrationWorkshop/master/Shared/SourceApps/Databases/TimeTracker.bak" -OutFile "c:\Databases\timetracker.bak"
SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "RESTORE DATABASE [TimeTracker] FROM DISK='C:\Databases\timetracker.bak' WITH MOVE 'tempname' TO 'C:\Databases\timetracker.mdf', MOVE 'TimeTracker_Log' TO 'C:\Databases\timetracker_log.ldf'" >> C:\Databases\db.log

Invoke-WebRequest "https://raw.githubusercontent.com/ivegamsft/AppMigrationWorkshop/master/Shared/SourceApps/Databases/Classifieds.bak" -OutFile "c:\Databases\Classifieds.bak"
SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "RESTORE DATABASE [Classifieds] FROM DISK='C:\Databases\Classifieds.bak' WITH MOVE 'Database' TO 'C:\Databases\classifieds.mdf', MOVE 'Database_log' TO 'C:\Databases\classifieds_log.ldf'" >> C:\Databases\db.log

Invoke-WebRequest "https://raw.githubusercontent.com/ivegamsft/AppMigrationWorkshop/master/Shared/SourceApps/Databases/Jobs.bak" -OutFile "c:\Databases\Jobs.bak"
SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "RESTORE DATABASE [Jobs] FROM DISK='C:\Databases\Jobs.bak' WITH MOVE 'EmptyDatabase' TO 'C:\Databases\jobs.mdf', MOVE 'EmptyDatabase_log' TO 'C:\Databases\jobs_log.ldf'" >> C:\Databases\db.log

Invoke-WebRequest "https://raw.githubusercontent.com/rellismicrosoft/appmigrationtemp/master/IBuySpyv3.bak" -OutFile "c:\Databases\IBuySpyv3.bak"
SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "RESTORE DATABASE [IBuySpyv3] FROM DISK='C:\Databases\IBuySpyv3.bak' WITH MOVE 'IBuySpyv3_Data' TO 'C:\Databases\IBuySpyv3_Data.mdf', MOVE 'IBuySpyv3_Log' TO 'C:\Databases\IBuySpyv3_Log.ldf'" >> C:\Databases\db.log

SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "USE timetracker; CREATE USER [${env:computername}\AppsSvcAcct]; EXEC sp_addrolemember 'db_owner', '${env:computername}\AppsSvcAcct'" >> C:\Databases\db.log
SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "USE classifieds; CREATE USER [${env:computername}\AppsSvcAcct]; EXEC sp_addrolemember 'db_owner', '${env:computername}\AppsSvcAcct'" >> C:\Databases\db.log
SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "USE jobs; CREATE USER [${env:computername}\AppsSvcAcct]; EXEC sp_addrolemember 'db_owner', '${env:computername}\AppsSvcAcct'" >> C:\Databases\db.log
SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!"-Q "USE IBuySpyv3; CREATE USER [${env:computername}\AppsSvcAcct]; EXEC sp_addrolemember 'db_owner', '${env:computername}\AppsSvcAcct'" >> C:\Databases\db.log

SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "USE timetracker; EXEC sp_addrolemember 'db_owner', '${env:computername}\AppsSvcAcct'" >> C:\Databases\db.log
SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "USE classifieds; EXEC sp_addrolemember 'db_owner', '${env:computername}\AppsSvcAcct'" >> C:\Databases\db.log
SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "USE jobs; EXEC sp_addrolemember 'db_owner', '${env:computername}\AppsSvcAcct'" >> C:\Databases\db.log
SQLCMD -S lpc:${env:computername} -U sqladmin -P "password1234!" -Q "USE IBuySpyv3; EXEC sp_addrolemember 'db_owner', '${env:computername}\AppsSvcAcct'" >> C:\Databases\db.log

#install the "old" web apps from the app migration workshop
c:\windows\system32\inetsrv\APPCMD delete site "Default Web Site"

mkdir C:\Apps

DownloadAndExpand -AppName "TimeTracker"
c:\windows\system32\inetsrv\APPCMD add apppool /name:"TimeTrackerAppPool" /managedPipelineMode:"Integrated"
c:\windows\system32\inetsrv\APPCMD add site /name:TimeTracker /id:1 /bindings:http://${env:computername}:8083 /physicalPath:C:\Apps\TimeTracker
c:\windows\system32\inetsrv\APPCMD set site TimeTracker "/[path='/'].applicationPool:TimeTrackerAppPool"

DownloadAndExpand -AppName "Classifieds"
c:\windows\system32\inetsrv\APPCMD add apppool /name:"ClassifiedsAppPool" /managedPipelineMode:"Classic"
c:\windows\system32\inetsrv\APPCMD add site /name:Classifieds /id:2 /bindings:http://${env:computername}:8081 /physicalPath:C:\Apps\Classifieds
c:\windows\system32\inetsrv\APPCMD set site Classifieds "/[path='/'].applicationPool:ClassifiedsAppPool"

DownloadAndExpand -AppName "Jobs"
c:\windows\system32\inetsrv\APPCMD add apppool /name:"JobsAppPool" /managedPipelineMode:"Integrated"
c:\windows\system32\inetsrv\APPCMD add site /name:Jobs /id:3 /bindings:http://${env:computername}:8082 /physicalPath:C:\Apps\Jobs
c:\windows\system32\inetsrv\APPCMD set site Jobs "/[path='/'].applicationPool:JobsAppPool"

DownloadNewApps -AppName "ibuyspy"
c:\windows\system32\inetsrv\APPCMD add apppool /name:"IBuySpyAppPool" /managedPipelineMode:"Integrated"
c:\windows\system32\inetsrv\APPCMD add site /name:IBuySpy /id:4 /bindings:http://${env:computername}:8084 /physicalPath:C:\Apps\ibuyspy
c:\windows\system32\inetsrv\APPCMD set site IBuySpy "/[path='/'].applicationPool:IBuySpyAppPool"

c:\windows\system32\inetsrv\appcmd set config /section:applicationPools "/[name='TimeTrackerAppPool'].processModel.identityType:SpecificUser" "/[name='TimeTrackerAppPool'].processModel.userName:${env:computername}\AppsSvcAcct" "/[name='TimeTrackerAppPool'].processModel.password:password1234!"
c:\windows\system32\inetsrv\appcmd set config /section:applicationPools "/[name='ClassifiedsAppPool'].processModel.identityType:SpecificUser" "/[name='ClassifiedsAppPool'].processModel.userName:${env:computername}\AppsSvcAcct" "/[name='ClassifiedsAppPool'].processModel.password:password1234!"
c:\windows\system32\inetsrv\appcmd set config /section:applicationPools "/[name='JobsAppPool'].processModel.identityType:SpecificUser" "/[name='JobsAppPool'].processModel.userName:${env:computername}\AppsSvcAcct" "/[name='JobsAppPool'].processModel.password:password1234!"
c:\windows\system32\inetsrv\appcmd set config /section:applicationPools "/[name='IBuySpyAppPool'].processModel.identityType:SpecificUser" "/[name='IBuySpyAppPool'].processModel.userName:${env:computername}\AppsSvcAcct" "/[name='IBuySpyAppPool'].processModel.password:password1234!"

Invoke-WebRequest "https://go.microsoft.com/fwlink/?linkid=2088631" -OutFile "c:\Apps\dotnet48.exe"
Start-Process C:\Apps\dotnet48.exe -ArgumentList "/q /norestart /log c:\temp\" -Wait

#finally reboot
Restart-Computer -Force