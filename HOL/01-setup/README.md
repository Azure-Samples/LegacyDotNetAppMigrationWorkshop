# Setting up the source environment using Resource Manager Templates

## Overview

In this lab, you will deploy a pre-built environment that you will use for the labs. The automated template will create 4 environments. Here is what is deployed:

## Applications
* Time tracker.  a .NET framework 3.5 web application with a SQL backend running on IIS7
* Jobs. a .NET framework 3.5 web application with a SQL backend running on IIS7
* Classifieds.  a .NET framework 3.5 web application with a SQL backend running on IIS7
* IBuySpy. A modernized webapp utilizing .Net4.8 and a SQL backend.

## Source environment
* Azure Resource group / Azure VNet/Subnets / Azure Storage Account configured to emulate a customer "on-prem" environment
* 1 Windows Server 2022 VM with Active Directory installed and configured (under development - coming in next version)
* 1 Windows Server 2019 VM with SQL 2022 and IIS installed and configured with the above apps utilizing local accounts
* 1 Windows Server 2016 VM with SQL 2017 and IIS installed and configured with the above apps utilizing local accounts
* 1 Windows Server 2012 VM with SQL 2014 and IIS installed and configured with the above apps utilizing local accounts
* 1 Windows Server 2008R2 VM with SQL 2008 and IIS installed and configured with the above apps utilizing local accounts

## Target environment

* Azure Kubernetes service with Hybrid Networking and windows containers
* Azure Container Registry
* Azure KeyVault
* 4 Azure SQL databases
* 1 Windows Server 2022 VM that will act as a domain controller
* Point-to-Point VPN connectivity (simulated using VNet Pairing for this exercise)

## Prerequisites

* An active Azure Subscription
* You are contributor at the subscription level

## Exercises

This hands-on-lab has the following exercises:

1. [Exercise 1: Deployment of Azure resources](#exercise-1-deployment-of-azure-resources)
2. [Exercise 2: Monitoring your deployment](#ex4)

### Exercise 1: Deployment of Azure resources

For the deployment, we are using Azure Bicep to deploy the resources and setup the legacy applications for the labs. 

1. Open a Bash or PowerShell terminal and clone the repository from its source

    ```powershell
    git clone https://github.com/Azure-Samples/LegacyDotNetAppMigrationWorkshop.git
    ```
2. Navigate to the repo folder. 
3. Before deploying, you will need to update the following values in the [main.json](../../Shared/IaaS/Bicep/configs/main.json):
   1. apppassword - Password for the application account on the Virtual Machine
   2. adminPassword - Password for the Virtual Machine 
   3. sqlAuthenticationPassword - Password for the SQL database on the Virtual Machine
   4. ipAddressforRDP - Set this to your IP address for RDP access to the jump boxes
   
4. Open a Bash or PowerShell terminal on your local machine then change directories to the folder with the Bicep code.
   ```
   cd Shared/IaaS/Bicep

5. Set the environment variable for the region you wish to deploy to, and run the deployment to build the source environment.

    ```powershell
    Set-Variable -Name 'Location' -Value 'EastUS'
    az deployment sub create --location $Location --template-file main.bicep
    ```
    
### Exercise 4: Monitoring your deployment<a name="ex4"></a>

----
Although you can monitor your deployment from a PowerShell command prompt without any issues, CloudShell has a fixed timeout of **20 minutes**, if your deployment takes more than it to complete (our case, this deployment takes approximately 35 minutes) 

You will see the following message:

  ![image](./media/pic8.png)

Since CloudShell is based on containers, when you reconnect, a new session will be presented to you and the deployment will be lost.

As mentioned before, if your deployment was executed from a PowerShell command prompt in a Virtual Machine or your own physical computer, it will not timeout and you will see the result of the deployment like this one:

  ![image](./media/pic7.png)

The idea of this exercise is to show you how to monitor a deployment, that is independent from your deployment method (PowerShell command prompt, Azure CLI, Visual Studio, CloudShell, SDK, etc.). One method is through the Resource Group's blade's Deployment property.

1. Go to the Azure Portal (http://portal.azure.com)

2. In the portal, in the left navigation pane, click `Resource Groups`

    ![image](./media/02-01-c.png)

3. From the Resource Group list, select the one deployed in HOL 1 (e.g. AppModernization-RG)

    ![image](./media/02-01-d.png)

4. From the Resource Group blade, there is a left menu item list, click on `Deployments`

    ![image](./media/pic4.png)

5. This will list all deployments executed and being executed, there is a column with the status of the deployment.

    ![image](./media/pic5.png)



## Summary

In this hands-on lab, you learned how to:

* Use the Azure Cloud Shell
* Deploy Azure resources from an automated template
* Log on to the Azure Portal
* Use Deployment blade item of the Resource Group to monitor a deployment

----

Copyright 2023 Microsoft Corporation. All rights reserved. Except where otherwise noted, these materials are licensed under the terms of the MIT License. You may use them according to the license as is most appropriate for your project. The terms of this license can be found at https://opensource.org/licenses/MIT.

