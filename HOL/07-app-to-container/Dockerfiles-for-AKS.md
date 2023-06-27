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

