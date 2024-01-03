# Use the Azure CLI to create a storage account to store the Terraform state files.
This storage account will be used to store the state of each deployment step and will be accessed by Terraform to reference values stored in the various deployment state files.

1. Using powershell login to the Azure subscription that you'll be deploying into with your credentials.

   ```PowerShell
   az login
   az account set --subscription <YOUR SUBSCRIPTION ID>
   ```
2. A PowerShell script titled "setupStateStore.ps1" has been supplied in the repository folder "Shared\IaaS\Terraform\scripts\" you may choose to run this script to create the needed storage account or continue with the instructions below to create the storage account using Azure cli.  
&nbsp;
    To run the script in PowerShell navigate to the repository folder "Shared\IaaS\Terraform\scripts\" the script should be run with the following parameters
    ```
    .\setupStateStore.ps1 "$resourceGroupName=<resource group name>" "$location=<location>" "$storageAccountName=<storage account name>"
    ```  
    Note the values used for storage creation for use in later steps. continue on to [Deploy AKS Cluster](./aks-deploy.md)
    &nbsp;
   
3. Create some variables to start with about where your storage account will live.
   
    ```PowerShell
    $REGION=<REGION>
    $STORAGEACCOUNTNAME=<UNIQUENAME>
    $CONTAINERNAME=akscs
    $TFSTATE_RG=tfstate
    ```
4. Create a Resource Group.
    
    ```PowerShell
    az group create --name $TFSTATE_RG --location $REGION
    ```

5. Create a Storage Account.

    ```PowerShell
    az storage account create -n $STORAGEACCOUNTNAME -g $TFSTATE_RG -l $REGION --sku Standard_LRS
    ```

6. Create a Storage Container within the Storage Account.

    ```PowerShell
    az storage container-rm create --storage-account $STORAGEACCOUNTNAME --name $CONTAINERNAME
    ```

Key points:

* For this example and for simplicity, public access is allowed to this Azure storage account for storing Terraform state. In a production deployment, it is recommended to restrict access to this storage account using a [storage firewall, service endpoint, or private endpoint](https://learn.microsoft.com/azure/storage/common/storage-network-security).
* Azure storage accounts require a globally unique name. To learn more about troubleshooting storage account names, see [Resolve errors for storage account names](https://learn.microsoft.com/azure/azure-resource-manager/templates/error-storage-account-name).

# Next Step
:arrow_forward: [Deploy AKS Cluster](./aks-deploy.md)