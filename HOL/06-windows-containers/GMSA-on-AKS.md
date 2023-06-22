# Windows Containers on AKS with GMSA

## Overview

In this lab, you will learn how to:

* Setup Group Managed Service Accounts (GMSA) on AKS 
* Configure your application for GMSA
* Deploy an application using GMSA

## Prerequisites

Ensure you have the following:

* You have an Azure Subscription
* You have completed HOL 1 setup

## Exercises

This hands-on-lab has the following exercises:

- [Windows Containers on AKS with GMSA](#windows-containers-on-aks-with-gmsa)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Exercises](#exercises)
    - [Exercise 1: Configure GMSA with the AKS PowerShell module](#exercise-1-configure-gmsa-with-the-aks-powershell-module)
      - [How to validate your GMSA integration before deployment](#how-to-validate-your-gmsa-integration-before-deployment)
    - [Exercise 2: Configure your application for deployment](#exercise-2-configure-your-application-for-deployment)
      - [Import the application to your container registry](#import-the-application-to-your-container-registry)
      - [Update manifest](#update-manifest)
    - [Exercise 3: Deploy your application on AKS](#exercise-3-deploy-your-application-on-aks)
      - [Verify your workload deployed](#verify-your-workload-deployed)
      - [Debugging](#debugging)
  - [Summary](#summary)

### Exercise 1: Configure GMSA with the AKS PowerShell module<a name="ex1"></a>
The set of resources you deployed in HoL 1 included an Azure Kubernetes cluster that is setup for Windows Container deployments. Since our application uses Group Managed Service Accounts (GMSA), we need to properly configure our cluster for GMSA usage. 

1. First, we need to enable gMSA integration on the AKS cluster. Run the following command to enable gMSA:
   ```
    az aks update \
    --resource-group **<Name of your Resource Group>** \
    --name **<Name of your AKS cluster>** \
    --enable-windows-gmsa
   
   ```
    
2. Add your login identity to the Key Vault access policy of the KeyVault you deployed in HoL 1. Assign Secret Management (Get, List, Set, Delete, Recover)
3. If not already connected, connect to your Domain Controller using Bastion via [RDP](https://learn.microsoft.com/azure/bastion/bastion-connect-vm-rdp-windows) or [SSH](https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh-windows). See [HOL 1](../01-setup/) if you haven't deployed the infrastructure already.
4. Complete all of the steps in the [setup instructions](https://learn.microsoft.com/virtualization/windowscontainers/manage-containers/gmsa-aks-ps-module) on the *gMSA on AKS PowerShell Module* and the *Configure gMSA on AKS with PowerShell Module* pages. It is optional to complete the steps on the *Validate gMSA on AKS with PowerShell Module* page. 
   - For the KeyVault used in the setup, use the KeyVault deployed as apart of this reference implementation. The module will check if a KeyVault with that name exists before creating the secret with the GMSA credentials.
   - For the managed identity used in the setup, use the managed identity deployed as apart of this reference implementation. The module will check if a managed identity with that name exists before creating a new one.
5. Make note of the GMSA Credential Spec name you used in the configuration for the next exercise.

#### How to validate your GMSA integration before deployment

To validate that your cluster is successfully retrieving your GMSA, go into your domain controller local server menu, go to Tools and select Event Viewer. Look under ActiveDirectory events. Look at the contents of the most recent events for a message that says "A caller successfully fetched the password of a group managed service account." The IP address of the caller should match one of your AKS cluster IPs. 


### Exercise 2: Configure your application for deployment<a name="ex2"></a>

#### Import the application to your container registry
To run the application container image, you will first need to import the Windows Server 2019 LTSC image to your Azure Container Registry that was deployed as a part of HoL 1. Once this image is imported, you will reference it in the workload's manifest file rather than the public image from Microsoft Container Registry.

1. If not already connected, connect to the jump box using Bastion via [RDP](https://learn.microsoft.com/azure/bastion/bastion-connect-vm-rdp-windows) or [SSH](https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh-windows). See [HOL 1](../01-setup/) if you haven't deployed the infrastructure already. 
2. Open a new Bash terminal on your jumpbox.
3. Run the following command to import the image needed for the application
   ```
   az acr import -n <ACR name> --source mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019
   ```
4. Run the following command to verify it was properly imported:
   ```
    az acr repository show -n <ACR name> --image windows/servercore/iis:windowsservercore-ltsc2019
    ```
#### Update manifest

1. Using the same Bash terminal, login into your GitHub account. Clone this repository to your jumpbox. 
    ```bash
    git clone <Your GitHub repo URL>
    ```  
2. Navigate to the [manifests folder](./manifests/) to find the [application manifest](./manifests/deployment_sampleapp.yml) for this exercise. Update the [manifest file](./manifests/deployment_sampleapp.yml) for the sample application with your GMSA name (look for **< GMSA Credential Spec Name >** in the manifest), application container registry name (Look for **< Registry Name >** in the manifest) and the load balancer subnet (look for **< Subnet Name >**).

### Exercise 3: Deploy your application on AKS<a name="ex3"></a>

1. Using the same Bash terminal as the previous exercise, navigate to the [manifests folder](./manifests/)
2. Create a namespace for your application by running ```kubectl create namespace simpleapp```
3. Run ```kubectl apply -n simpleapp```

#### Verify your workload deployed

1. Run the following commands to verify your workload deployed:
    ```
    kubectl get deployment -n simpleapp
    kubectl get pods -n simpleapp
    kubectl describe service -n simpleapp
    ```
2. Copy the ip address displayed by running `kubectl describe ingress -n simpleapp` on your jumpbox, open a browser, navigate to the IP address obtained above from the ingress controller and explore your website.

#### Debugging 
If your application isn't loading, there could be an issue with the GMSA integration. To debug this, we need to check the status of the pods and the GMSA webhook.

1. Check the status of your pods by running  `kubectl get pods -n simpleapp` on your jumpbox. 
   - If the status is Running, you're good to go. 
   - If the status of your pods is CrashLoopBackOff, run `kubectl logs <pod name>` to debug. This status likely means that your credential spec file is misconfigured or the cluster permissions to your KeyVault are misconfigured. An example credential spec can be found [here](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#create-a-credential-spec). When you look through your credential spec file, ensure that the DnsName, NetBiosName and GroupManagedServiceAccounts match the values from your domain controller.

## Summary

In this hands-on lab, you learned how to:

* Configure and test a Windows Container gSMA Account on AKS


----

Copyright 2023 Microsoft Corporation. All rights reserved. Except where otherwise noted, these materials are licensed under the terms of the MIT License. You may use them according to the license as is most appropriate for your project. The terms of this license can be found at https://opensource.org/licenses/MIT.