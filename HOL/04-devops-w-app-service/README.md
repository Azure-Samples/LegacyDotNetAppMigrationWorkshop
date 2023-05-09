# DevOps

## Overview

In this lab, you will learn how to:

* Create a sample application and configure it for Continuous Integration
* Create infrastructure as code
* Create a CI/CD pipeline
* Deploy the application to Azure

## Prerequisites

> NOTE: This HoL does _not_ depend on other modules to be completed. You can use your personal machine to complete this lab, but we recommend you use the jumpbox deployed in the previous HoL. 

* An Azure subscription are required for the completion of the lab.
* Create a repository in GitHub
* .NET 7.0 installed on your development machine. Use [https://www.microsoft.com/net/download/windows](https://www.microsoft.com/net/download/windows). We recommend you complete this HOL on the jumpbox created in the previous HOL because it is a known environment and it has .NET 7.0 pre-installed. 

## Exercises

This hands-on-lab has the following exercises:

- [Exercise 0: Setup Environment](#ex0)
- [Exercise 1: Create an Application](#ex1)
- [Exercise 2: Create the Environment](#ex2)
- [Exercise 3: Create the CI/CD Pipeline](#ex3)

### Exercise 0: Setup Environment<a name="ex0"></a>
1. 1. If not already connected, connect to the jump box using Bastion via [RDP](https://learn.microsoft.com/azure/bastion/bastion-connect-vm-rdp-windows) or [SSH](https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh-windows). See [HOL 1](../01-setup/)
2. Login into your GitHub account. Create a new repository and clone it to your jumpbox. 
    ```bash
    git clone <Your GitHub repo URL>
    ```
### Exercise 1: Create an Application<a name="ex1"></a>

----

For the purpose of this lab, we are going to create a .NET 7.0 application. You will do this from the jump box.

1. If not already connected, connect to the jump box using Bastion via [RDP](https://learn.microsoft.com/azure/bastion/bastion-connect-vm-rdp-windows) or [SSH](https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh-windows). See [HOL 1](../01-setup/)

2. Ensure that you have downloaded .NET on the machine [Download .NET 7.0](https://www.microsoft.com/net/download/thank-you/dotnet-sdk-2.1.200-windows-x64-installer)

3. Launch a PowerShell window

4. Use the `dotnet` command below to create a new MVC application, restore dependencies, build, and run it.

    ```powershell
    cd <Your GitHub Repository Name>
    md dotnetapp
    cd dotnetapp
    dotnet new mvc -f net7.0
    dotnet restore
    dotnet build
    dotnet run
    ```

5. By default, the running webapp will be running on `http://localhost:5000`. It should look like the screenshot below.

    ![Base App Screenshot][1]

### Exercise 2: Create the Environment<a name="ex2"></a>

----

Now that we have an app we need to get the supporting infrastructure in Azure to support it. We will be using a CI/CD pipeline and want to deploy the infrastructure as part of that pipeline. This will be done via an Azure Resource Manager templates. A wealth of Resource Manager templates can be found on the [Azure GitHub repo](https://github.com/Azure/azure-quickstart-templates).

For this HoL, we are going to use the template for [Deploying a Web App with custom deployment slots](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.web/webapp-custom-deployment-slots).

> Note: While this template has a _"Deploy to Azure"_ button, we will be using it in our CI/CD pipeline.

1. Download the _azuredeploy.json_ and _azuredeploy.paramaters.json_ file to your local directory. We will use PowerShell to pull the files locally

    ````powershell
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.web/webapp-custom-deployment-slots/azuredeploy.json'  -OutFile azuredeploy.json
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.web/webapp-custom-deployment-slots/azuredeploy.parameters.json' -OutFile azuredeploy.parameters.json

    ````

1. Your local directory should look like the screenshot below.

  ![Folder Screenshot][2]

### Exercise 3: Create the CI/CD Pipeline<a name="ex3"></a>

----

Before adding new files, we will define files that we don't want to track in the repo.

1. Create a file called `.gitignore` in the root of the directory by running the following command:
   ```powershell
   dotnet new gitignore
   ```

2. The code below will add all the files to track and commit them to the GitHub repo. From the root directory of the project:

      ```powershell
      git add -A
      git commit -am "feat: Add initial files"
      git push -u origin --all
      ```

### Setup workflow

----

With the code in GitHub, the CI/CD pipeline needs to be configured. For this lab, we will be creating a GitHub workflow to deploy to Azure App Service. 

1. Create a folder, .github/workflows, in your GitHub repo with your application. 
2. Locate the [App Service Deployment Pipeline](./.github/workflows/deploy-app-service.yml) in this repo. Place the workflow in .github/workflows folder you just created. This workflow will run when you push changes to your application in the main branch.  

### Deployment


### Exercise 4:  Test<a name="ex4"></a>

----

1. With the successful deployment, open your Azure Portal and navigate to the WebApp.

1. Click on the url to launch the site.

## References

_ADVANCED TOPIC (Preview Feature as of 02/27/2018)_ - [CI as Code via YAML file](https://docs.microsoft.com/en-us/vsts/build-release/actions/build-yaml).

  [1]: ./media/HOL05_01.png
  [2]: ./media/HOL05_02.PNG
  [3]: ./media/HOL05_03.png
  [4]: ./media/HOL05_04.png
  [5]: ./media/HOL05_05.png
  [6]: ./media/HOL05_06.png
  [7]: ./media/HOL05_07.png
  [8]: ./media/HOL05_08.png
  [9]: ./media/HOL05_09.png

## Summary

In this hands-on lab, you learned how to:

* Create a GitHub workflow 
* Configure source control integration for continuous integration

----

Copyright 2023 Microsoft Corporation. All rights reserved. Except where otherwise noted, these materials are licensed under the terms of the MIT License. You may use them according to the license as is most appropriate for your project. The terms of this license can be found at https://opensource.org/licenses/MIT.
