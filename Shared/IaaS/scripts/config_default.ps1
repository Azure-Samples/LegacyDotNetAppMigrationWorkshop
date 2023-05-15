Install-WindowsFeature -name Web-Server -IncludeManagementTools

#upgrade dot net (4.5.2)
Install-WindowsFeature .NET-Framework-45-Features