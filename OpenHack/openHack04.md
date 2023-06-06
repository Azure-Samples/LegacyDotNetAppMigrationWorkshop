# Open Hack - Challenge 04

---

Some legacy applications require native Windows functionality like:

* Authentication
* Delegation
* Database security

Containers are a good way to move applications to the cloud. Move the application to a container and retain this functionality (Virtual Machine or AKS).

## Use the [Custom application](../HOL/06-windows-containers/site/) for this exercise

## Helpful information

If you don't have a Windows machine but want to use one as a container host, we have deployed one to the environment set up in Open Hack 1.

## Stretch Goals

* Add access to file share to the app with delegation
* Add LDAP call to app

## Helpful Links
[Group Managed Service Accounts on AKS](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/gmsa-aks-ps-module)
[AKS Windows Baseline](https://github.com/Azure/aks-baseline-windows)
[Running Windows Containers on AKS](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/windows-containers-on-aks)