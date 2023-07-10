# Monitoring your new environment

## Overview

In this lab you will learn how to monitor the environment using Azure services

## Prerequisites

Ensure you have completed the previous HOLs

## Excercies

- [Monitoring your new environment](#monitoring-your-new-environment)
	- [Overview](#overview)
	- [Prerequisites](#prerequisites)
	- [Excercies](#excercies)
		- [Exercise 1: Azure Monitor](#exercise-1-azure-monitor)
	- [Summary](#summary)



WebApp/IIS
[Collect IIS logs with the Log Analytics agent in Azure Monitor](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-data-sources-iis-logs)

[AppInsights Overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview?tabs=net)

### Exercise 1: Azure Monitor<a name="ex1"></a>
Azure Monitor is available the moment you create an Azure subscription. The Activity log immediately starts collecting events about activity in the subscription, and platform metrics are collected for any Azure resources you created. Features such as metrics explorer are available to analyze data. Other features require configuration. This scenario identifies the configuration steps required to take advantage of all Azure Monitor features. It also makes recommendations for which features you should use and how to determine configuration options based on your particular requirements.

You require at least one Log Analytics workspace to enable Azure Monitor Logs, which is required for:

- Collecting data such as logs from Azure resources.
- Collecting data from the guest operating system of Azure Virtual Machines.
- Enabling most Azure Monitor insights.

1. Login to https://shell.azure.com
    ```powershell
    Select-AzureRmSubscription -Subscription "<your subscription name>"
    ```
1. Run the az group create command to create a resource group or use an existing resource group. To create a workspace, use the az monitor log-analytics workspace create command.
	```powershell
	az group create --name <myGroup> --location <myLocation>
    az monitor log-analytics workspace create --resource-group <myGroup> \
       --workspace-name <myWorkspace>
	```
Some monitoring of Azure resources is available automatically with no configuration required. To collect more monitoring data, you must perform configuration steps.
![image](./media/best-practices-azure-resources.PNG)

	
[Collect tenant and subscription logs](https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-data-collection#collect-tenant-and-subscription-logs)

[Collect resource logs and platform metrics](https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-data-collection#collect-resource-logs-and-platform-metrics)

##[Enable Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-data-collection#enable-insights)

Insights provide a specialized monitoring experience for a particular service. They use the same data already being collected such as platform metrics and resource logs, but they provide custom workbooks that assist you in identifying and analyzing the most critical data. Most insights will be available in the Azure portal with no configuration required, other than collecting resource logs for that service. See the monitoring documentation for each Azure service to determine whether it has an insight and if it requires configuration.

The following insights are much more complex than others and have more guidance for their configuration:

- [VM insights](https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-data-collection#monitor-virtual-machines)
- [Container insights](https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-data-collection#monitor-containers)
- [Monitor applications](https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-data-collection#monitor-applications)
- [Enable Container insights for Azure Kubernetes Service (AKS) cluster](https://learn.microsoft.com/en-Us/azure/azure-monitor/containers/container-insights-enable-aks?tabs=azure-cli)
- [Monitoring cluster status](https://learn.microsoft.com/en-us/azure/architecture/microservices/logging-monitoring#monitoring-cluster-status)



## Summary

In this hands-on lab, you learned how to:

* Set up monitoring using Azure services

---

Copyright 2023 Microsoft Corporation. All rights reserved. Except where otherwise noted, these materials are licensed under the terms of the MIT License. You may use them according to the license as is most appropriate for your project. The terms of this license can be found at https://opensource.org/licenses/MIT.
