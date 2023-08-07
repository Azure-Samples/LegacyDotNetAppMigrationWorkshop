# .NET Migration to Azure Kubernetes Service Guide
## Architectural and Non-Functional Requirements Checklist
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
| Virtual Directory/Filesystem | It is a common practice to store web app content under site root or on the mounted virtual directories. Any files that require persistent changes will be reset during pod restarts and will not transfer across pods. It is recommended that any files that have changes that need to persist to store them in a persistent volume mounted to the node. External storage guarantees the maintenance of files and is accessible across all pods which supports consistency across all instances of the application. Find more info [here](https://learn.microsoft.com/azure/aks/concepts-storage#storage-classes) about the different types of storage you can mount to identify the option that best fits your applications data storage requirements. |
| Registry | Applications writing to the registry are supported in AKS, but since containers are stateless, you should be mindful of these actions because anything that needs to persist beyond the life of the pod will be reset when the pods are destroyed or restarted. |
| Session Management and Caching | It is common to use session state in .NET Core to manage user information and to create sticky sessions. Since containers are stateless, it is recommended to transition state management models to use services such as Redis Cache to store the session information outside of the cluster to prevent deletion when pods are destroyed or restarted. This model also helps reduce memory consumption on the container. Please refer to [documentation on using Azure Redis Cache](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-aspnet-session-state-provider) for state management for .NET Core.  |
| Domain Services| If your application is using Windows Authentication with an on-premises domain controller, it is recommended that you create a 2nd domain controller in Azure that is synced to your on premises Domain Controller. The Azure Domain Controller reduces latency for authentication requests for your application and simplifies the networking required to connect your application to your on-premises resources. See our [HoL 1](./HOL/01-setup/README.md)|

## Things to consider
|  Topic       |  Solution |
|--------------|-----------|
| Scaling | |
|Ingress||
