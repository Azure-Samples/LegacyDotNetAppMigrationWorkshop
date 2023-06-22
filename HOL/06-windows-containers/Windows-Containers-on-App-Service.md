# Windows Containers on Azure App Service

## Overview

In this lab, you will learn how to:

* Containerize an application for App Service
* Deploy a Windows Container onto App Service

## Prerequisites

Ensure you have the following:

* You have an Azure Subscription
* You have completed HOL 1-setup

## Exercises

This hands-on-lab has the following exercises:

- [Windows Containers on Azure App Service](#windows-containers-on-azure-app-service)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Exercises](#exercises)
    - [Exercise 1: Containerize your application ](#exercise-1-containerize-your-application-)
    - [Exercise 2: Deploy your application on App Service](#exercise-2-deploy-your-application-on-app-service)
      - [Database Update](#database-update)
  - [Summary](#summary)

### Exercise 1: Containerize your application <a name="ex1"></a>
1. Grab the name, admin username and password for your Azure Container Registry from the Azure Portal
1. Run the following commands in Bash or PowerShell to containerize your application:
   ```
        cd C:\Apps\IBuySpyV3\web
        docker login <ACR Name>.azurecr.io -u <Admin Username for ACR> -p <Password for ACR>
        docker build -t <ACR Name>.azurecr.io/ibuyspyv3:v1 -f Dockerfile .
        docker push <ACR Name>.azurecr.io/ibuyspyv3:v1 
    ```

### Exercise 2: Deploy your application on App Service
Now that we have our application containerized, let's deploy it on App Service as a Docker Container. 

1. Navigate to the Azure portal and type App Service into the search bar. 
2. Click on *Create* on the App Services Web App icon to create a new App Service. Configure the Basics tab:
   - Resource Group: <Your Resource Group from  HoL 1>
   - Name: Needs to be unique e.g., IBuySpyV3<Random 5 digit number>
   - Publish: Docker Container
   - Operating System: Windows
   - Region: Region where your resources are deployed from HoL 1
   - Pricing Plans: If don't already have one created from the previous labs, click *Create new* and give it a meaningful name. Premium V3 is recommended for the pricing plan. 
   ![Basics](media/Basics%20App%20Service%20Setup.png)
3. Configure the Docker tab as below:
   - Image Source: *Azure Container Registry*
   - Registry: <Your ACR registry>
   - Image: ibuyspyv3
   - Tag: v1
   ![Docker tab App Service](media/Docker%20Tab%20App%20Services.png)
4. Leave the defaults for the other tabs. Click *Review + create* 

#### Database Update

As mentioned in the previous lab (HoL 5), you have an Azure SQL database available in your resource group deployed through HoL 1. It has been pre-populated with the appropriate tables and data necessary for the IBuySpy application. Similar to what you did in HoL 5 with updating the connection string, you will need to repeat here. If you completed HoL 5, you can reuse the KeyVault secret you created there and skip steps 3-6 below. 

1. Create a System Assigned Managed Identity through App Service by going to Settings then Identity inside your App Service in the Azure Portal. Turn the button for Status to On and hit Save.
   ![App Service Managed Identity](media/App%20Service%20MI.jpg)
2. Navigate to your Azure KeyVault in the Portal. Go to Access control (IAM), click Add then Add role assignment. Select the KeyVault Secrets User role. On the next screen, select Managed identity then select your App Service Managed Identity from the dropdown and hit Select. Click Review + assign. Now your App Service has access to read the secrets in your KeyVault.
3. To create the secret with the database connection string, you will need to assign yourself the role of KeyVault Secrets Officer in the RBAC permissions of the KeyVault.

    Navigate to your Azure KeyVault in the Portal. Go to Access control (IAM), click Add then Add role assignment. Select the KeyVault Secrets Officer role. On the next screen, search for your username. Click Review + assign. Now you have access to manage the secrets in your KeyVault.

4. Grab the connection string from the SQL Database by going to you SQL database in the Portal then to Settings and then Connection Strings. Select the ADO.NET (SQL authentication) option and replace {your_password} with the password you provided in the Bicep deployment. 
5. Create a secret in the KeyVault with the value as the connection string by go to your KeyVault then Objects and Secrets
6. Select Generate/Import. Make the secret name something you will remember or save the name somewhere for reference. You will need it in a minute. The secret value should be the connection string from the previous step. Hit Create once you've filled out the secret name and value.

7. Go to the Configuration section in the app service. Add two environment variables:

    - ```DataConnectionString = ConnectionStringPaas```
    - ```ConnectionStringPaas = @Microsoft.KeyVault(SecretUri=https://{Your KeyVault name}.vault.azure.net/secrets/{Your Secret name}/) OR @Microsoft.KeyVault(VaultName=<Your KeyVault name>;SecretName={Your Secret name})```
  
    Hit Save and wait for the app to restart.

Once the app has successfully restarted, navigate to the URL for your application and you should be able to see the fully functional app with products listed on the site. If you do not see your application, check your connection string again in your Azure KeyVault.

## Summary

In this hands-on lab, you learned how to:

* Setup and deploy a Windows container on Azure App Service


----

Copyright 2023 Microsoft Corporation. All rights reserved. Except where otherwise noted, these materials are licensed under the terms of the MIT License. You may use them according to the license as is most appropriate for your project. The terms of this license can be found at https://opensource.org/licenses/MIT.