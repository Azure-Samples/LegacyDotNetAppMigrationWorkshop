# Open Hack - Challenge 01

---

This document outlines the format for an Open Hack version of the App modernization workshop.

## Deploy Azure Infrastructure

* [ARM Template](../../Shared/ARM-NewIaaS)

## Configure Source Applications

* [ ] Get source code [zip files](../../Shared/SourceApps/Apps)
* [ ] Get [database backups](../../Shared/SourceApps/Databases)
* [ ] Configure web applications

### Applications

* Time Tracker
* Classifieds
* Jobs
* Optional
  * iBuySpy
  * Pet Shop

## Inventory Source Applications

Information you are looking for includes but may not be limited to:

* SSL Certificate
  * SPN/Kerberos
  * App Pool ID
  * Delegation Info
  * Ports and Protocols
  * DNS Name(s)
  * Hard Coded IP Addresses
  * Identity Federation
  * Security Information
    * Groups
  * Windows Integrated
* Source Operating System
* IIS Settings
* DB Versions
* DB Settings

To perform this inventory you can use the following tools:

## Select migration path for applications

Options include

* Full PaaS (Front End and Back End)
  * Azure App Service
  * Azure Container Apps
* Hybrid (Combination of VMs and PaaS)
* Containers
  * Virtual Machines or scalesets
  * Azure Kubernetes Service

## Identify pre-requisites

This might include but is not limited to:

* Azure Virtual Networks
* Resource Groups
* PaaS Services

## For Discussion

* Do you think you have enough information to migrate the app?
* Can you identify any potential blockers?
* Were the tools helpful?

## Helpful Resources

* [Migration checklist when moving to Azure App Service](https://techcommunity.microsoft.com/t5/apps-on-azure-blog/checklist-for-migrating-web-apps-to-app-service/ba-p/3810991)
* [Azure App Service Migration Tools](https://azure.microsoft.com/products/app-service/migration-tools/)
* [Microsoft Data Migration Assistant](https://learn.microsoft.com/sql/dma/dma-overview?view=sql-server-ver16)
* [MAP Toolkit](https://learn.microsoft.com/training/modules/sql-server-discovery-using-map/)
* [Azure Migrate](https://azure.microsoft.com/en-us/services/azure-migrate/)

### 3rd Party Tools

This listing is not complete or meant to endores any product over another

* [CloudAtlas](https://www.cloudatlasinc.com/)