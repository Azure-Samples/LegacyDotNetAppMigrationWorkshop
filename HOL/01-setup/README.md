# Setting up the source environment using Resource Manager Templates

## Overview

In this lab, you will deploy a pre-built environment that you will use for the labs. The automated template will create 3 environments. Here is what is deployed:

## Applications
* Time tracker.  A classic webapp that runs on IIS in IIS7 mode.  Uses SQL Backend.
* Jobs. A classic webapp that runs on IIS in IIS7 mode. Uses SQL Backend.
* Classifieds.  A classic webapp that runs on IIS in IIS7 mode.  Uses SQL Backend
* IBuySpy.  A modernized webapp utilizing .Net4.8 and a SQL backend.

## Source environment
* Azure Resource group / Azure Vnet/Subnets / Azure Storage Account configured to emulate a customer "on-prem" environment
* 1 Windows Server 2022 VM with Active Directory installed and configured (under development - coming in next version)
* 1 Windows Server 2019 VM with SQL 2022 and IIS installed and configured with the above apps utilizing local accounts
* 1 Windows Server 2016 VM with SQL 2017 and IIS installed and configured with the above apps utilizing local accounts
* 1 Windows Server 2012 VM with SQL 2014 and IIS installed and configured with the above apps utilizing local accounts
* 1 Windows Server 2008R2 VM with SQL 2008 and IIS installed and configured with the above apps utilizing local accounts

## Target environment

* Azure Kubernetes service with Hybrid Networking and windows containers
* Azure Container Registry
* Azure Keyvault
* 4 Azure SQL databases
* 1 Windows Server 2022 VM that will act as a domain controller
* Point-to-Point VPN connectivity (simulated using Vnet Pairing for this exercise)

## Prerequisites

* An active Azure Subscription
* You are contributor at the subscription level

## Exercises

This hands-on-lab has the following exercises:

1. [Exercise 1: Opening Cloud Shell for the first time](#ex1)
1. [Exercise 2: Downloading the materials to the Cloud Shell environment](#ex2)
1. [Exercise 3: Deployment of Azure resources](#ex3)
1. [Exercise 4: Monitoring your deployment](#ex4)
1. [Exercise 5: Set up your Visual Studio online account](#ex5)

### Exercise 1: Opening Cloud Shell for the first time<a name="ex1"></a>

----

1. Open your browser and go to <a href="https://shell.azure.com" target="_new">https://shell.azure.com</a>

1. Sign on with `Microsoft Account` or `Work or School Account` associated with your Azure subscription

    ![image](./media/02-01-a.png)

    ![image](./media/02-01-b.png)

1. If you have access to more than one subscription, Select the Azure directory that is associated with your Azure subscription

1. If this is the first time you accessed the Cloud Shell, `Select` "PowerShell (Windows)" when asked which shell to use.

    ![image](./media/pic1.jpg)

    > Note: If this is not the first time and it is the "Bash" shell that starts, please click in the dropdown box that shows "Bash" and select "PowerShell" instead.

1. If you have at least contributor rights at subscription level, please select which subscription you would like the initialization process to create a storage account and click "Create storage" button.

    ![image](./media/pic2.jpg)

1. You should see a command prompt like this one:

    ![image](./media/pic3.jpg)

### Exercise 2: Downloading artifacts to the Cloud Shell environment<a name="ex2"></a>

----

1. If not already open, open your browser and navigate to <a href="https://shell.azure.com" target="_new">https://shell.azure.com</a>. Proceed with authentication if needed.

1. The Azure Cloud Shell persists its data on a mapped folder to Azure Files service. Change directories to `C:\Users\ContainerAdministrator\CloudDrive` with

    ```powershell
    cd C:\Users\ContainerAdministrator\CloudDrive
    ```
    > If you need to delete the directory and start over run the following:
    ```powershell
    Remove-Item .\AppMigrationWorkshop\ -Recurse -Force
    ```
1. Clone the repository from its source

    ```powershell
    git clone https://github.com/Azure-Samples/LegacyDotNetAppMigrationWorkshop.git
    ```

### Exercise 3: Deployment of Azure resources<a name="ex3"></a>

----

In the automated deployment, we are using PowerShell Desired State Configuration (DSC) modules to help configure the virtual machines. You need to download them to the environment, so they can be deployed. The deployment script uses these modules to build the zip file that is used by the PowerShell DSC VM Extension and uploads it to the staging storage account.

1. If not already open, open your browser and navigate to <a href="https://shell.azure.com" target="_new">https://shell.azure.com</a>. Proceed with Authentication if needed.

1. Change the current folder to the location of cloned files

    ```powershell
    cd C:\Users\ContainerAdministrator\CloudDrive\AppMigrationWorkshop\Shared\ARM-NewIaaS\dsc
    ```

1. Copy the following folders to the Cloud Shell PowerShell modules folder

    ```powershell
    copy-item cDisk -Destination C:\users\ContainerAdministrator\CloudDrive\.pscloudshell\WindowsPowerShell\Modules -Recurse -Force
    copy-item xActiveDirectory -Destination C:\users\ContainerAdministrator\CloudDrive\.pscloudshell\WindowsPowerShell\Modules -Recurse -Force
    copy-item xComputerManagement -Destination C:\users\ContainerAdministrator\CloudDrive\.pscloudshell\WindowsPowerShell\Modules -Recurse -Force
    copy-item xDisk -Destination C:\users\ContainerAdministrator\CloudDrive\.pscloudshell\WindowsPowerShell\Modules -Recurse -Force
    copy-item xNetworking -Destination C:\users\ContainerAdministrator\CloudDrive\.pscloudshell\WindowsPowerShell\Modules -Recurse -Force
    ```

1. Change directories to the location of the ARM deployment script

    ````powershell
    cd ..
    ````

1. This solution was created using Visual Studio 2017 and it provides automatically a deployment script, please execute it by replacing some of the values as follows:

    ````powershell
    .\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation <DEPLOYMENT_LOCATION> `
                                        -ResourceGroupName <RESOURCE_GROUP_NAME> `
                                        -UploadArtifacts `
                                        -TemplateFile .\azuredeploy.json `
                                        -TemplateParametersFile .\azuredeploy.parameters.json

    ````

    Where:

    ````xml
    <DEPLOYMENT_LOCATION> - Azure Location the template will for the location property of all resources
    <RESOURCE_GROUP_NAME> - Name of the resource group where all resources will be created
    ````

    Example:

    ````powershell
    .\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation westus `
                                    -ResourceGroupName AppModernization-RG `
                                    -UploadArtifacts `
                                    -TemplateFile .\azuredeploy.json `
                                    -TemplateParametersFile `
                                    .\azuredeploy.parameters.json
    ````

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

1. In the portal, in the left navigation pane, click `Resource Groups`

    ![image](./media/02-01-c.png)

1. From the Resource Group list, select the one deployed in HOL 1 (e.g. AppModernization-RG)

    ![image](./media/02-01-d.png)

1. From the Resource Group blade, there is a left menu item list, click on `Deployments`

    ![image](./media/pic4.png)

1. This will list all deployments executed and being executed, there is a column with the status of the deployment.

    ![image](./media/pic5.png)

1. Your master deployment item is called `azuredeploy-<MMDD>-<HHMM>`, this is the main item to monitor, if you want more details about it (all other deployments being shown here are created by the main deployment). Click `azuredeploy-<MMDD>-<HHMM>`.

    ![image](./media/pic6.png)

1. This will show all deployments chained to the master deployment. If there is any issue or if you want to check more details you can click on `Operation Details` or `Related Events` link.

    ![image](./media/pic10.png)

1. You will notice that your deployment is completed after status of `azuredeploy-<MMDD>-<HHMM>` deployment is Succeeded and it jumps to the top of the deployment list.

    ![image](./media/pic11.png)

### Exercise 5: Set up your Visual Studio Online Account<a name="ex5"></a>

----

1. Open a browser and navigate to https://my.visualstudio.com

1. Sign in with your Microsoft Account or create a new one. If prompted, choose the correct account type

    ![image](./media/2018-05-18_18-15-50.png)

1. If this is the first time, wait for your account to be created.

    ![image](./media/2018-05-18_18-17-57.png)

1. From the menu, click on `Get started` for Visual Studio Team Services

    ![image](./media/2018-05-18_18-18-42.png)

1. Enter a name for your Visual Studio Online account. Choose `git` as the Repository type

    ![image](./media/2018-05-18_18-20-28.png)

1. Choose Change Details and change the name of your project

    ![image](./media/2018-05-18_19-48-33.png)

1. Once your account is created, your first project will be initialized.

1. If you did not name your first project, or want to can change it, select the Gear icon from main menu

    ![image](./media/2018-05-18_19-27-15.png)

1. Find the project, click on the ellipsis and choose `Rename`

    ![image](./media/2018-05-18_19-27-40.png)

1. Enter `ApplicationMigrationVSO` and click `Ok`

    ![image](./media/2018-05-18_19-28-20.png)

1. You wll prompted with a warning after renaming your project. Check `I understand...` and click `Rename Project`

    ![image](./media/2018-05-18_19-28-45.png)

1. Your project is now renamed

    ![image](./media/2018-05-18_19-29-14.png)


## Summary

In this hands-on lab, you learned how to:

* Use the Azure Cloud Shell
* Deploy Azure resources from an automated template
* Log on to the Azure Portal
* Use Deployment blade item of the Resource Group to monitor a deployment

----

Copyright 2016 Microsoft Corporation. All rights reserved. Except where otherwise noted, these materials are licensed under the terms of the MIT License. You may use them according to the license as is most appropriate for your project. The terms of this license can be found at https://opensource.org/licenses/MIT.

