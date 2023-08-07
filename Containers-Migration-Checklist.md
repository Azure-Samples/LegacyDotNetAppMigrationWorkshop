# .NET Migration to Azure Kubernetes Service Guide
## Architectual and Non-Functional Requirements Checklist
|  Topic       |  Guidance |
|--------------|-----------|
|||

## Runtime Environment Checklist
|  Topic       |  Guidance |
|--------------|-----------|
|||

## Application Dependencies Checklist
|  Topic       |  Guidance  |
|--------------|------------|
| Virtual Directory/Filesystem | It is a common practice to store web app content under site root or on the mounted virtual directories. It is recommended that any files that have changes that need to persist to store them in a persistent volume mounted to the node. Find more info [here](https://learn.microsoft.com/azure/aks/concepts-storage#storage-classes).  |
| Registry | Applications writing to the registry are supported in AKS, but since containers are stateless, you should be mindful of these actions because anything that needs to persist beyond the life of the pod will be reset when the pods are destroyed and restarted.  |
| Session Management and Caching | It is common to use session state in .NET Core to manage user sessions and to create sticky sessions. Since containers are stateless, it is recommended to transition state management models that use services such as Redis Cache to store the session information outside of the cluster to prevent deletion when pods are restarted. Please refer to [documentation on using Azure Redis Cache](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-aspnet-session-state-provider) for state management for .NET Core.  |
| Domain Services| If your application is using Windows Authentication with an on-premises domain controller, it is recommended that you create a 2nd domain controller in Azure that is synced to your on premises Domain Controller. The Azure Domain Controller reduces latency for authentication requests for your application.|

## Things to consider
|  Topic       |  Solution |
|--------------|-----------|
| Scaling | |
|Ingress||
