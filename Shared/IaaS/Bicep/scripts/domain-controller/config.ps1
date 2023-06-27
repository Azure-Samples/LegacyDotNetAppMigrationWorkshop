#Disable IE Enhanced Security Configuration

function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

Disable-InternetExplorerESC

$password = ConvertTo-SecureString -String "Admin#123" -AsPlainText -Force

Import-Module ADDSDeployment

Initialize-Disk -Number 1 -PartitionStyle MBR

New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter F

Format-Volume -DriveLetter F -FileSystem NTFS

Add-WindowsFeature -name ad-domain-services -IncludeManagementTools 

Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName "appmigrationworkshop.com" -DatabasePath "F:\\\\NTDS" -LogPath "F:\\\\NTDS" -SYSVOLPath "F:\\\\SYSVOL" -DomainNetbiosName "appmigws" -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force

Set-DnsServerForwarder -IPAddress 168.63.129.16

exit 0