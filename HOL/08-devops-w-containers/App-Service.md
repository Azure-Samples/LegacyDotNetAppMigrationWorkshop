# CI/CD with Windows Containers on Azure App Service

## Overview

In this lab, you will learn how to:

* Containerize an application for App Service
* Deploy a Windows Container onto App Service

## Prerequisites

Ensure you have the following:

* You have an Azure Subscription
* You have completed [HoL 1-setup](../01-setup/README.md)
* You have completed [HoL 6 - App Service](../06-windows-containers/Windows-Containers-on-App-Service.md)

## Exercises

This hands-on-lab has the following exercises:

- [CI/CD with Windows Containers on Azure App Service](#cicd-with-windows-containers-on-azure-app-service)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Exercises](#exercises)
    - [Exercise 1: Setup CI/CD](#exercise-1-setup-cicd)

### Exercise 1: Setup CI/CD
In HoLs 4 & 5, you learned how to setup CI/CD for App Service with source code. Now that we have our application containerized from HoL 7, let's enable CI/CD for Windows containers. 

1. We need to enable Basic Authentication on the App Service to support CI/CD. 
   1. Navigate to the Configuration tab on the left navigation panel. 
   2. Click the *General Settings* tab 
   3. Turn *Basic Authentication*  to On
   4. Hit *Save*
   ![Basic Auth Setup](../../HOL/04-devops-w-app-service/media/Basic%20Authentication.png)

2. If not already connected, connect to the jump box using Bastion via [RDP](https://learn.microsoft.com/azure/bastion/bastion-connect-vm-rdp-windows) or [SSH](https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh-windows). See [HOL 1](../01-setup/) if you haven't deployed the infrastructure already. 
3. Login into your GitHub account. Create a new repository and clone it to your jumpbox. 
    ```bash
    git clone <Your GitHub repo URL>
    ```
4. Copy the files for the IBuySpy application to your base repo folder. The folder structure should be /app/web/ where the web folder contains the core application files.
   ![Folder Structure](media/Folder%20Structure.png)
5. Run the following commands in your Bash terminal to commit and push your application to the repo:
   ```
    git add -A
    git commit -am "feat: Add application files"
    git push -u origin --all
   ```
6. Before adding in our workflow, we need a few variables defined in our GitHub repository first:
   1. ACR_Name - The name of the Azure Container Registry in your resource group from HoL 1
   2. AzureAppService_ContainerUsername - The Admin username of your ACR
   3. AzureAppService_ContainerPassword - The Admin password of your ACR
   4. AzureAppService_PublishProfile - The publish profile from your Azure App Service from HoL 6
   
   The GitHub workflow provided will build the Docker image using the Dockerfile provided, tag the version as the hash of the commit that triggered the build, push it your ACR and then use the publish profile you provided to deploy it to your App Service. 
7. Create a folder in your repo called *.github/workflows*
8. Copy the [workflow](./workflows/Deploy-Container-App-Service.yml) to your *.github/workflows* folder. 
9. Commit the changes to your repository:
    ```
    git add -A
    git commit -am "feat: Add deployment workflow"
    git push -u origin --all
   ```
   The workflow has a trigger for pushes to main. You can navigate to the *Actions* tab to check the status of the build and deployment. Once the container has been deployed to App Service, it can take a few minutes for it come up. 
   