# Identifying a migration path 

![Decision Tree](media/Decision%20Tree%20-%20NET.png)

.NET application configurations vary depending on organizational requirements, security requirements and age of source code. With enterprise customers, you will typically encounter older .NET applications using .NET framework and earlier versions of .NET Core. Customers that are using modern .NET versions like 6 and 7 have an easier migration path because those versions are supported by all Azure PaaS Services. Those with older applications face several key organizational decisions around authentication, database migration and how much control they want over their environment. 

In the decision tree above, you will notice three migration options: [Azure App Service](https://learn.microsoft.com/azure/app-service/), [Azure Kubernetes Service](https://learn.microsoft.com/azure/aks/), and [Azure Virtual Machines](https://learn.microsoft.com/azure/virtual-machines/). Below you'll find a brief description of each option and what customer conditions warrant using each. 

# Basic Migrations Options

## Azure App Service

For those using modern versions of .NET and who want less granular control over their environment, [Azure App Service](https://learn.microsoft.com/azure/app-service/) is a good option because it includes automatic scaling, zone redundancy, integration with other Azure Services such as KeyVault, and monitoring with [Azure Application Insights](https://learn.microsoft.com/azure/azure-monitor/). Customers with .NET framework applications can also use App Service if they're looking for a more hands off approach to managing their application, but it does not support Windows Authentication and other native Windows features such as accessing the registry or GAC.

## Azure Kubernetes Service
For those using modern or legacy versions of .NET and who want more control over their environment, AKS is a great option as a container based service that allows for lots of customization. Because it's a container based service, another benefit of AKS is that it supports Windows Authentication using Group Managed Service Accounts (GMSA) and can support native Windows features. If the customer has data that needs to persist beyond the lifecycle of the container/pod, they can mount storage to the node to maintain the data externally via an Azure Storage Account. If secrets or registry keys need to be backed up, they can be stored in an [Azure KeyVault](https://learn.microsoft.com/azure/key-vault/general/overview) to persist. 

### **Considerations with using AKS**
#### **Customer Perception**
Customers like the idea of Kubernetes because it's innovative and flexible, but they often do not have a good enough understanding of how it works or do not have the technical personnel to support its maintenance. This is something you want to consider when discussing this option with the customer because Azure App Service or Azure Virtual Machines may be a better choice if they do not feel comfortable with the upkeep for AKS. 

#### **Feasibility**
Customers running .NET framework applications can use AKS, but they need to be mindful of the size of their containerized applications. Image size will depend on the .NET version, dependencies and size of the source code, but the base .NET framework runtime Docker image is ~14 Gb. While this is manageable with a Virtual Machine, it's difficult to scale an image with that size quickly. It's recommended to have the customer use a multi-stage build and use a base Windows Server 2019 or 2022 image where they only install the bare necessities to run the application. The [AKS Windows Baseline](https://github.com/Azure/aks-baseline-windows) developed by another team at Microsoft was able to reduce their sample .NET framework image to ~6 Gb. This size is more manageable, but it may still require alternatives to scale appropriately for load. The [AKS Windows Baseline Reference Documentation]() details what's called a "hot spare" solution for scaling where you have the number of nodes you need + 1 running at any given time. For more information on this approach check out the linked documentation.   

## Azure Virtual Machines

Migrating from on premises to Azure Virtual Machines is the simplest option for moving customers to the cloud. It has the most parity with infrastructure on premises with the added features of Azure including vertical and horizontal scaling, availability zones, automated backups and integration with other Azure services such as [Azure Storage](https://learn.microsoft.com/azure/storage/common/storage-introduction) and [Azure Site Recovery](https://learn.microsoft.com/azure/virtual-machines/overview). 

# Additional Migration Options

## Azure Container Apps
[Azure Container Apps](https://learn.microsoft.com/azure/container-apps/compare-options#azure-container-apps) are backed by AKS and are ideally suited for microservices running containers. The benefits of this platform are a cross between App Service and AKS. It supports automatic scaling, zone redundancy and containerization. It requires less overhead than AKS. It's a good option for your customer if they want to dip their toe into Kubernetes without making the full commitment.    