# Windows Containers: How to containerize a legacy app for AKS

## Overview

In this lab, you will learn how to:

* Containerize an existing application with Docker optimized for AKS

In the other lab in this section, you learn(ed) how to use Image2Docker to convert an ASP.NET application to a Dockerfile. While this tool helps us handle the process in an automated fashion, it does not use optimized images to host your application. One of the big benefits of AKS is its ability to scale quickly and efficiently. .NET Framework takes up a lot of space on a machine and the bigger the image, the hardest it is for AKS to scale. 

In this lab, you will learn how to construct a Dockerfile for a .NET framework application using best practices for AKS. 

## Prerequisites

* Ensure you have completed the previous labs
* Ensure you have installed the following:
  * Powershell 5.0 or later
  * Docker

## Exercises

This hands-on-lab has the following exercises:

- [Windows Containers: How to containerize a legacy app for AKS](#windows-containers-how-to-containerize-a-legacy-app-for-aks)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Exercises](#exercises)
    - [Exercise 1: Basic Dockerfile structure](#exercise-1-basic-dockerfile-structure)
    - [Exercise 2: Gather information for source apps](#exercise-2-gather-information-for-source-apps)
      - [.NET Version](#net-version)
      - [Uses SQL database as the backend that is hosted locally on the same VM](#uses-sql-database-as-the-backend-that-is-hosted-locally-on-the-same-vm)
      - [IIS \& Port 80](#iis--port-80)
- [================================================================================================](#)
- [Runtime Stage](#runtime-stage)
- [================================================================================================](#-1)

### Exercise 1: Basic Dockerfile structure

For the purposes of this lab, we'll focus on the IBuySpy sample application which runs .NET 4.8. 

We want to split our Dockerfile into 2 stages: build and runtime. 

The build stage uses the full .NET framework SDK to build the application and produce the deploy artifacts necessary for running the application. By doing this, we avoid needing an image with extra packages and libraries our application doesn't require to run.

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
- Runs on Port 80

Let's break down each of the requirements and identify how they fit into our image build.

#### .NET Version

.NET 4.8 tells us that we need an image that either already has 4.8 installed or we need to install it using a package manager. For our builder stage we need an image that has the .NET 4.8 SDK with nuget and msbuild to compile our application. Below you'll see the build stage for IBuySpy.

We use the most recent version of Windows Server from the Microsoft Container Registry that has the 4.8 SDK installed. We then create a site directory to hold our application files, copy the application files from our repository to the container, restore the nuget packages and build the application with msbuild. 

```
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8.1-windowsservercore-ltsc2022 as builder

SHELL ["powershell"]

WORKDIR C:\site

COPY . C:\site

RUN cd app/web; `
	nuget restore ..\IBuySpyV3.sln -PackagesDirectory ..\packages; `
	msbuild /p:Configuration=Release ..\IBuySpyV3.sln
```
#### Uses SQL database as the backend that is hosted locally on the same VM

Since the application is dependent on a local SQL database, we need to migrate our SQL database before deploying our containerized application to AKS. The HoL 1 deployment deployed a SQL database for you that matches the IBuySpy local SQL database. 

For deploying on AKS, you can pass updated values for your Web.config in through a config map which we will discuss in the DevOps with containers section for deploying to AKS. You won't need to modify any of your connection strings in your Web.config before deploying it to AKS as a container. 

For deploying on App Service, App Service merges the App Settings from the Configuration section into the Web.config on the application. You won't need to modify any of your connection strings in your Web.config before deploying it to App Service as a container. 

#### IIS & Port 80

We need to host our application on IIS which means we need our runtime stage to use an image that has IIS 7 installed. See below. 

```
# ================================================================================================
# Runtime Stage
# ================================================================================================

FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022

SHELL ["powershell"]

EXPOSE 80

WORKDIR C:\site
