# CI/CD with Windows Containers on Azure Kubernetes Service

## Overview

In this lab, you will learn how to:

* Containerize an application for Azure Kubernetes Service
* Deploy a Windows Container onto Azure Kubernetes Service

## Prerequisites

Ensure you have the following:

* You have an Azure Subscription
* You have completed [HoL 1-setup](../01-setup/README.md)
* You have completed [HoL 7 - App to Container](../07-app-to-container/README.md)

## Exercises

This hands-on-lab has the following exercises:

- [CI/CD with Windows Containers on Azure Kubernetes Service](#cicd-with-windows-containers-on-azure-kubernetes-service)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Exercises](#exercises)
    - [Exercise 0: Setup Environment](#exercise-0-setup-environment)
    - [Exercise 1: Setup environment for CI/CD](#exercise-1-setup-environment-for-cicd)
    - [Exercise 2: Setup CI/CD](#exercise-2-setup-cicd)
  - [Summary](#summary)


### Exercise 0: Setup Environment<a name="ex0"></a>
1. If not already connected, connect to the jump box using Bastion via [RDP](https://learn.microsoft.com/azure/bastion/bastion-connect-vm-rdp-windows) or [SSH](https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh-windows). See [HOL 1](../01-setup/) if you haven't deployed the infrastructure already. 
2. Login into your GitHub account. Create a new repository and clone it to your jumpbox if you haven't already in the previous labs. If you have a GitHub repository from one of the previous labs, you may continue to use that repository. 
    ```bash
    git clone <Your GitHub repo URL>
    ```
### Exercise 1: Setup environment for CI/CD
In HoLs 6 & 7, you learned how to deploy an application using GMSA onto AKS and how to containerize your application for deployment onto a Windows container platform. During this exercise, we are going to use a GitHub workflow to automate the build and deployment of the IBuySpyV3 application to AKS. 

1. Copy the files for the IBuySpy application to your base repo folder. The folder structure should be /app/web/ where the web folder contains the core application files.
   ![Folder Structure](media/Folder%20Structure.png)
2. Modify your Web.config file to include the string to your SQL database. App Service provides a way to set the AppSettings outside of the application, but AKS does not so we need to manually add it to the deployment. To do this, change these values:
   1. ConnectionStringPaas -> Your SQL DB string
   2. DataConnectionString -> ConnectionStringPaas

3. Create a manifests folder in the base of your repository and place the [deployment.yaml](manifests/deployment.yml) file in there. 
4. Run the following commands in your Bash terminal to commit and push your application to the repo:
   ```
    git add -A
    git commit -am "feat: Add application files"
    git push -u origin --all
   ```
5.  [Register an app in the Azure portal for your application](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app#register-an-application)
6.  Give your application Contributor access to your subscription by going to your Subscription:
    1.  Click on *Access control (IAM)*
    2.  Click on *Add* then *Add role assignment*
    3.  Click on *Privileged administrator roles* then *Contributor*, hit *Next*
    4.  Click *Select members* and search for the name of your application.
    5.  Select the application and hit Next
    6.  Click *Review + assign* to create the role assignment
7.  Give you application [Federated credentials](https://learn.microsoft.com/azure/active-directory/workload-identities/workload-identity-federation-create-trust?pivots=identity-wif-apps-methods-azp#github-actions). Federated credentials allow certain services such as GitHub to have permission to deploy Azure resources without having to specify a client secret. It sends a claim to Azure which then returns a token. 

    Use the following values for the credential:
    
      - Organization = #Your GitHub Organization Name
      - Repository = #Your Repository Name
      - Entity Type = branch
      - Github branch name = main
      - Name = GitHubDeployMain
8. Before adding in our workflow, we need a few secrets defined in our GitHub repository first:
   1. ACR_Name - The name of the Azure Container Registry in your resource group from HoL 1
   2. ACR_ContainerUsername - The Admin username of your ACR
   3. ACR_ContainerPassword - The Admin password of your ACR
   4. AZURE_CLIENT_ID - The Client Id of the App you registered in step 4
   5. AZURE_TENANT_ID - The Tenant Id of your Azure AD Tenant
   6. AZURE_SUBSCRIPTION_ID - The Subscription Id of your Azure Subscription
   7. AKS_CLUSTER_NAME - The name of your AKS cluster from the resource group you deployed in HoL 1
   8. AKS_RESOURCE_GROUP - The name of the resource group you deployed in HoL 1
   
   The GitHub workflow provided will build the Docker image using the Dockerfile provided, tag the version as the hash of the commit that triggered the build, push it your ACR and then use the kube credentials retrieved by azure login to deploy your application to AKS. 

### Exercise 2: Setup CI/CD

1. Create a folder in the root of your repo called *.github/workflows*
2. Copy the [workflow](./workflows/Deploy-Container-AKS.yml) to your *.github/workflows* folder. 
3. Commit the changes to your repository:
    ```
    git add -A
    git commit -am "feat: Add deployment workflow"
    git push -u origin --all
   ```
   The workflow has a trigger for pushes to main. You can navigate to the *Actions* tab to check the status of the build and deployment. Once the container has been deployed to App Service, it can take a few minutes for it come up. 

4. Once the workflow has completed, run the following commands on a Bash or PowerShell terminal to get the external IP of your cluster:
   ```
   az login
   az aks get-credentials -n CLUSTER_NAME -g CLUSTER_RESOURCE_GROUP
   kubectl get services -n windowsapp
   ```
   Copy the External-IP address and paste it into your browser to see your application. 

## Summary

In this hands-on lab, you learned how to:

* Use CI/CD to deploy Windows Containers to AKS

----
Copyright 2023 Microsoft Corporation. All rights reserved. Except where otherwise noted, these materials are licensed under the terms of the MIT License. You may use them according to the license as is most appropriate for your project. The terms of this license can be found at https://opensource.org/licenses/MIT.