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
| Domain Services| AKS supports Windows Authentication and Group Managed Service Accounts (GMSA) through a [PowerShell module](https://learn.microsoft.com/virtualization/windowscontainers/manage-containers/gmsa-aks-ps-module). If your application is using Windows Authentication and/or GMSA with an on-premises domain controller, it is recommended that you create a 2nd domain controller in Azure that is synced to your on-premises Domain Controller. The Azure Domain Controller reduces latency for authentication requests for your application and simplifies the networking required to connect your application to your on-premises resources. See our [HoL 1](./HOL/01-setup/README.md) for an example of how to setup your Domain Controller in Azure.|

## Things to consider
|  Topic       |  Solution |
|--------------|-----------|
| Scaling | .NET Framework applications and some .NET Core applications require Windows for their runtime environment. Windows is a much bulkier OS than Linux and with .NET framework, the container image size increases drastically. When using Windows containers on AKS, it is recommended to keep your container images as lean as possible to facilitate auto-scaling to support load on your application. Using a base Windows Server 2022 image, multi-stage build and installing application dependencies on top are a few of the things that keep the image as small as possible. It is also recommended to set your image pull policy to IfNotPresent so that any new pods utilize the image cached on the node. For example, if your image is 10 GB, every time you need to scale to support incoming requests, your cluster has to spin up another 10GB pod and if it also has to pull the image from a remote image repository, it could take several minutes for that pod to come online. For more information on how to handle scaling with Windows containers on AKS, check out the [documentation](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/windows-containers-on-aks#node-and-pod-scaling) in the Azure Architecture center. |
| Ingress | Windows Containers are supported by most ingress controllers with a couple of caveats. <ul><li>Nginx supports ingress to Windows containers, but it must deployed on a Linux nodepool in the same cluster. </li><li>Application Gateway supports ingress to Windows Containers, but it does not support Windows Authentication. For guidance on handling ingress with Windows Authentication and GMSA, refer to the [AKS Windows baseline](https://github.com/Azure/aks-baseline-windows).</li></ul>|
