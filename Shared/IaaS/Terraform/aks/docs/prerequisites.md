# Prerequisites

1. An Azure subscription
 &nbsp;
   The subscription used in this deployment cannot be a free account; it must be a standard EA, pay-as-you-go, or Visual Studio benefit subscription. This is because the resources deployed here are beyond the quotas of free subscriptions.  
    &nbsp;

    The service principal initiating the deployment process must have the following minimal set of Azure Role-Based Access Control (RBAC) roles:

        - Contributor role is required at the subscription level to have the ability to create resource groups and perform deployments.
        - User Access Administrator role is required at the subscription level since you'll be performing role assignments to managed identities across various resource groups.
        - Global Admin on Azure AD Tenant is required for setting up Azure Application Proxy. This setup is done manually. An admin could perform this step for you as it's the last step in the setup after deploying your application. 
    Please follow [these instructions](https://learn.microsoft.com/azure/active-directory/develop/howto-create-service-principal-portal) to create a service principal in Azure. 
3. PowerShell terminal. This reference reference implementation uses PowerShell for deployment.
4. Latest [Azure CLI installed](https://learn.microsoft.com/cli/azure/install-azure-cli-windows?tabs=powershell#powershell)
5. [Terraform version 1.4.0 or greater](https://learn.microsoft.com/azure/developer/terraform/get-started-windows-bash?tabs=bash#4-install-terraform-for-windows)

# Next Step
:arrow_forward: [Setup state storage for Terraform](./state-storage.md)