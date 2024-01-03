# Deploy Azure Kubernetes Service

1. [Prerequisites](./prerequisites.md)
   
2. [Setup Azure storage to store the Terraform state](state-storage.md)

3. Login to Azure

    ```powershell
    az login 
    az account set --subscription <Your Subscription Id>
    ```

    Update the following values to your PowerShell instance:
    We will be running the commands using the service principal you created in [prerequisites](./prerequisites.md). You will need your SPN client ID, SPN tenant id and client secret. 
    Create the following variables for ease of use during deployment. 

    ```PowerShell
    $backendResourceGroupName="(Resource Group created in step 2)"
    $backendStorageAccountName="(Storage Account Created in Step 2)"
    $backendContainername="tfstate"
    $env:ARM_CLIENT_ID = "00000000-0000-0000-0000-000000000000"
    $env:ARM_CLIENT_SECRET = "12345678-0000-0000-0000-000000000000"
    $env:ARM_TENANT_ID = "10000000-0000-0000-0000-000000000000"
    $env:ARM_SUBSCRIPTION_ID = "20000000-0000-0000-0000-000000000000"
    ```

3. Deploy using Terraform Init, Plan and Apply. 

    ```PowerShell
    terraform init -input=false -backend-config="resource_group_name=$backendResourceGroupName" -backend-config="storage_account_name=$backendStorageAccountName" -backend-config="container_name=$backendContainername"
    ```

    Enter terraform init -reconfigure if you get an error saying there was a change in the backend configuration which may require migrating existing state.
    If you get an error about list of available provider versions, go with the `-upgrade` flag option to allow selection of new versions.

    ```PowerShell
    terraform plan 
    ```

    ```PowerShell
    terraform apply --auto-approve 
    ```

# Next Step
:arrow_forward: [Return to HOL 1](../../../../../HOL/01-setup/README.md)
