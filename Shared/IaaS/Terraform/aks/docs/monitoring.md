# Monitoring 

## AKS Cluster

### Overview

Container insights has been enabled and deployed with the cluster previous step, the references below give guidance on enabling container insights and monitoring Azure Kubernetes Service.

### Prerequisites

If you're connecting an existing AKS cluster to a Log Analytics workspace in another subscription, the Microsoft.ContainerService resource provider must be registered in the subscription with the Log Analytics workspace. For more information, see [Register resource provider](#https://learn.microsoft.com/en-Us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider).

### References

1. [Enable Container insights for Azure Kubernetes Service (AKS) cluster](https://learn.microsoft.com/en-Us/azure/azure-monitor/containers/container-insights-enable-aks?tabs=azure-cli)

2. [Monitoring cluster status](#https://learn.microsoft.com/en-us/azure/architecture/microservices/logging-monitoring#monitoring-cluster-status)


## Application Insights

Application Insights is an extension of Azure Monitor and provides application performance monitoring (APM) features. APM tools are useful to monitor applications from development, through test, and into production in the following ways:

Proactively understand how an application is performing.
Reactively review application execution data to determine the cause of an incident.

1. [Application Insights overview
](#https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview?tabs=net)

2. [Manage Application Insights resources by using PowerShell](https://learn.microsoft.com/en-us/azure/azure-monitor/app/powershell#create-application-insights-resources-by-using-a-powershell-cmdlet)

3. Application Insights Instrumentation 
    - [Application Insights for ASP.NET Core applications](#https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core?tabs=netcorenew%2Cnetcore6)
     - [Application Insights for your ASP.NET website](#https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net)
     - [Monitor your Node.js services and apps with Application Insights](#https://learn.microsoft.com/en-us/azure/azure-monitor/app/nodejs)
     - [Application Insights JavaScript SDK configuration](#https://learn.microsoft.com/en-us/azure/azure-monitor/app/javascript-sdk-configuration)
    - [Set up Azure Monitor for your Python application](#https://learn.microsoft.com/en-us/azure/azure-monitor/app/opencensus-python)