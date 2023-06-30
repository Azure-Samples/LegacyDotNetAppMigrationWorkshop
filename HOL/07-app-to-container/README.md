# Windows Containers: How to containerize a legacy app for AKS and App Service

## Overview

In this lab, you will learn how to:

* Containerize an existing application with Docker optimized for AKS and App Service

In the other lab in this section, you learn(ed) how to use Image2Docker to convert an ASP.NET application to a Dockerfile. While this tool helps us handle the process in an automated fashion, it does not use optimized images to host your application. One of the big benefits of AKS is its ability to scale quickly and efficiently. .NET Framework takes up a lot of space on a machine and the bigger the image, the harder it is for AKS to scale. 

In this lab, you will learn how to construct a Dockerfile for a .NET framework application using best practices for AKS. 

## Prerequisites

* Completed the resource deployment in [HoL 1](../01-setup/README.md)

## Exercises

This hands-on-lab has the following exercises:

- [Windows Containers: How to containerize a legacy app for AKS and App Service](#windows-containers-how-to-containerize-a-legacy-app-for-aks-and-app-service)
	- [Overview](#overview)
	- [Prerequisites](#prerequisites)
	- [Exercises](#exercises)
		- [Exercise 1: Basic Dockerfile structure](#exercise-1-basic-dockerfile-structure)
		- [Exercise 2: Gather information for source apps](#exercise-2-gather-information-for-source-apps)
			- [.NET Version](#net-version)
			- [Uses SQL database as the backend that is hosted locally on the same VM](#uses-sql-database-as-the-backend-that-is-hosted-locally-on-the-same-vm)
			- [IIS \& Port 80](#iis--port-80)
	- [Exercise 3: Put it all together and build your image](#exercise-3-put-it-all-together-and-build-your-image)

### Exercise 1: Basic Dockerfile structure

For the purposes of this lab, we'll focus on the IBuySpy sample application which runs .NET 4.8. 

We want to split our Dockerfile into 2 stages: build and runtime. 

The build stage uses the full .NET framework SDK to build the application and produce the deploy artifacts necessary for running the application. By doing this, we generate all of the build artifacts required for the application to run without having to have the full SDK in the runtime stage. 

The runtime stage uses a base WindowsServer Core image with IIS to host the application. During this stage, we'll enable only the Windows features our application needs to run including .NET Framework 45 and IIS remote administration for debugging. 

This type of optimization allows us to bring the image size from ~11.5 Gb to 5.5 Gb - a more than 50% reduction in size. 

See below for an example of the structure you will use to create your Dockerfile in the next exercise. 

```
# ================================================================================================
# Builder Stage
# ================================================================================================

FROM mcr.microsoft.com/dotnet/framework/sdk:4.8.1-windowsservercore-ltsc2022 as builder
...
...
# ================================================================================================
# Runtime Stage
# ================================================================================================

FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
...
...
```

### Exercise 2: Gather information for source apps

Let's think about what we know about the IBuySpy application.

- Running .NET 4.8
- Hosted on IIS 7
- Uses SQL database as the backend that is hosted locally on the same VM
- Not using Windows Authentication
- Runs on port 80

Let's break down each of the requirements and identify how they fit into our image build.

#### .NET Version

.NET 4.8 tells us that we need an image that either already has 4.8 installed or we need to install it using a package manager. For our builder stage we need an image that has the .NET 4.8 SDK with nuget and msbuild to compile our application. Below you'll see the build stage for IBuySpy.

```
# escape=`

# ================================================================================================
# Builder Stage
# ================================================================================================

FROM mcr.microsoft.com/dotnet/framework/sdk:4.8.1-windowsservercore-ltsc2022 as builder

SHELL ["powershell"]

WORKDIR C:\site

COPY . C:\site

RUN cd app/web; `
	nuget restore ..\IBuySpyV3.sln -PackagesDirectory ..\packages; `
	msbuild /p:Configuration=Release ..\IBuySpyV3.sln
```
We use the most recent version of Windows Server from the Microsoft Container Registry that has the 4.8 SDK installed. We then create a site directory to hold our application files, copy the application files from our repository to the container, restore the nuget packages and build the application with msbuild. 

#### Uses SQL database as the backend that is hosted locally on the same VM

Since the application is dependent on a local SQL database, we need to migrate our SQL database before deploying our containerized application to AKS. The HoL 1 deployment created an Azure SQL database from a backup of the local IBuySpy database. 

For deploying on AKS, you can pass updated values for your Web.config in through a config map which we will discuss in the DevOps with containers section for deploying to AKS. You won't need to modify any of your connection strings in your Web.config before deploying it to AKS as a container. 

For deploying on App Service, App Service merges the App Settings from the Configuration section into the Web.config on the application. You won't need to modify any of your connection strings in your Web.config before deploying it to App Service as a container. 

#### IIS & Port 80

We need to host our application on IIS which means we need our runtime stage to use an image that has IIS 7 installed. In the below code, you'll noticed that we're using the most recent version of Windows Server Core that includes IIS. 

We also noticed in the [inventory](#exercise-2-gather-information-for-source-apps) that our application runs on port 80. In the 3rd line of the Dockerfile, you'll see that we've exposed port 80 of the container to make the application accessible. 

After we expose the port, we go on to enable the necessary features for running the application including Web-Server, .NET Framework 4.5 and HTTP tracing for debugging. We then configure the IIS server and add an entrypoint.   

```
# ================================================================================================
# Runtime Stage
# ================================================================================================

FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022

SHELL ["powershell"]

EXPOSE 80

WORKDIR C:\site

#
## Setup Operating System
#
## Enable IIS Remote Administration
RUN Add-WindowsFeature Web-Server; `
    Add-WindowsFeature NET-Framework-45-ASPNET; `
    Add-WindowsFeature Web-Asp-Net45; `
    Add-WindowsFeature Web-Http-Tracing

## Debug Only: Remove for production
RUN net user localadmin Qwerty123456 /add; `
    net localgroup Administrators localadmin /add; ` 
    Install-WindowsFeature Web-Mgmt-Service; `
    New-ItemProperty -Path "HKLM:\software\microsoft\WebManagement\Server" -Name "EnableRemoteManagement" -Value 1 -Force

# Setup IIS Server
RUN New-WebAppPool "GMSAAppPool"; `
	# Configure root AppPool to run as LocalSystem 
	Set-ItemProperty `
		-Path "IIS:\AppPools\GMSAAppPool" `
		-Name "processModel" `
		-Value @{identitytype=0}; `
	# Replace Default Web Site
	Remove-WebSite -Name 'Default Web Site'; `
	New-WebSite `
		-Name "Site" `
		-Port 80 `
		-PhysicalPath "C:\site" `
		-ApplicationPool "GMSAAppPool"; `
	# Configure for Anonymous Authentication
	Set-WebConfigurationProperty `
		-Location "Site" `
		-PSPath IIS:\ `
		-Filter "system.webServer/security/authentication/anonymousAuthentication" `
		-Name "enabled" `
		-Value $true; `
	# Configure monitoring
	Set-WebConfigurationProperty `
		-pspath 'MACHINE/WEBROOT/APPHOST' `
		-filter "system.applicationHost/sites/siteDefaults/logFile" `
		-name "logTargetW3C" -value "File,ETW";


## Copy compiled files from Builder Stage
COPY --from=builder C:\site\app\web c:\site\
#
## Create Web Applications and configure authentication
#
## Debug Only: Enable verbose logging for kerberos in the Windows Event Viewer
RUN New-ItemProperty `
	-Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters `
	-Name LogLevel `
	-PropertyType DWord `
	-Value 1 `
	-Force

# Check application health against anonymous endpoint
HEALTHCHECK CMD powershell -command `  
    try { `
     $response = iwr http://localhost:80 -UseBasicParsing; `
     if ($response.StatusCode -eq 200) { return 0} `
     else {return 1}; `
    } catch { return 1 }

ENTRYPOINT	C:\\site\\metrichub\\runtime\\MetricHub.Entrypoint.exe;
```
## Exercise 3: Put it all together and build your image

Now that we have all of the pieces for building and running our application, let's put it all together and build it. 

Your Dockerfile should look like this: 

```
# escape=`

# ================================================================================================
# Builder Stage
# ================================================================================================

FROM mcr.microsoft.com/dotnet/framework/sdk:4.8.1-windowsservercore-ltsc2022 as builder

SHELL ["powershell"]

WORKDIR C:\site

COPY . C:\site

RUN cd app/web; `
	nuget restore ..\IBuySpyV3.sln -PackagesDirectory ..\packages; `
	msbuild /p:Configuration=Release ..\IBuySpyV3.sln

# ================================================================================================
# Runtime Stage
# ================================================================================================

FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022

SHELL ["powershell"]

EXPOSE 80

WORKDIR C:\site

#
## Setup Operating System
#
## Enable IIS Remote Administration
RUN Add-WindowsFeature Web-Server; `
    Add-WindowsFeature NET-Framework-45-ASPNET; `
    Add-WindowsFeature Web-Asp-Net45; `
    Add-WindowsFeature Web-Http-Tracing

## Debug Only: Remove for production
RUN net user localadmin Qwerty123456 /add; `
    net localgroup Administrators localadmin /add; ` 
    Install-WindowsFeature Web-Mgmt-Service; `
    New-ItemProperty -Path "HKLM:\software\microsoft\WebManagement\Server" -Name "EnableRemoteManagement" -Value 1 -Force

# Setup IIS Server
RUN New-WebAppPool "GMSAAppPool"; `
	# Configure root AppPool to run as LocalSystem 
	Set-ItemProperty `
		-Path "IIS:\AppPools\GMSAAppPool" `
		-Name "processModel" `
		-Value @{identitytype=0}; `
	# Replace Default Web Site
	Remove-WebSite -Name 'Default Web Site'; `
	New-WebSite `
		-Name "Site" `
		-Port 80 `
		-PhysicalPath "C:\site" `
		-ApplicationPool "GMSAAppPool"; `
	# Configure for Anonymous Authentication
	Set-WebConfigurationProperty `
		-Location "Site" `
		-PSPath IIS:\ `
		-Filter "system.webServer/security/authentication/anonymousAuthentication" `
		-Name "enabled" `
		-Value $true; `
	# Configure monitoring
	Set-WebConfigurationProperty `
		-pspath 'MACHINE/WEBROOT/APPHOST' `
		-filter "system.applicationHost/sites/siteDefaults/logFile" `
		-name "logTargetW3C" -value "File,ETW";


## Copy compiled files from Builder Stage
COPY --from=builder C:\site\app\web c:\site\
#
## Create Web Applications and configure authentication
#
## Debug Only: Enable verbose logging for kerberos in the Windows Event Viewer
RUN New-ItemProperty `
	-Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters `
	-Name LogLevel `
	-PropertyType DWord `
	-Value 1 `
	-Force

# Check application health against anonymous endpoint
HEALTHCHECK CMD powershell -command `  
    try { `
     $response = iwr http://localhost:80 -UseBasicParsing; `
     if ($response.StatusCode -eq 200) { return 0} `
     else {return 1}; `
    } catch { return 1 }

# Start the metric hub entrypoint
ENTRYPOINT	C:\\site\\metrichub\\runtime\\MetricHub.Entrypoint.exe;
```
1. If not already connected, connect to the jump box using Bastion via [RDP](https://learn.microsoft.com/azure/bastion/bastion-connect-vm-rdp-windows) or [SSH](https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh-windows). See [HOL 1](../01-setup/README.md) if you haven't deployed the infrastructure already. Remember you will need to put ```appmigws\``` before your VM username to login to the box since it is domain joined. 
2. Open up Docker Desktop for Windows by typing *Docker* into the Windows search box. Once it opens, go to your toolbar and right click on the tiny Docker icon. 
   1. If it says *Switch to linux containers*, that means it is configured to support Windows Containers
   2. If it says *Switch to windows containers*, click that option and confirm. Wait for it restart Docker before going to the next step.
3. Open a Git Bash terminal. 
4. Clone this repository to the jumpbox with the following command:
   ```
   git clone https://github.com/Azure-Samples/LegacyDotNetAppMigrationWorkshop.git
   ```
5. Unzip the [IBuySpy application](../../Shared/SourceApps/Apps/IBuySpy.zip) to a folder of your choosing
6. Copy the contents of the Dockerfile you created above into the existing Dockerfile with the application
7. If you'd like to test the container locally before deploying to AKS or App Service, you will need to update the SQL database connection string in the Web.config file. 
   1. Grab the connection string from your Azure SQL database in the Portal
   2. Replace the value for *ConnectionStringPaas* to your SQL connection string
8. Using your Bash terminal, run the docker build command from the web folder:
   ```
   cd app/web
   docker build -t ibuyspy:v1 -f Dockerfile .
   ```
9.  If you updated the SQL connection string, you can run the following command to test your container locally once it has finished the build:
	```
	docker run -d -p 80:80 ibuyspy:v1
	```
