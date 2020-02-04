# Setup

## Requirements

- [Azure Devops extension for Azure CLI](https://github.com/Azure/azure-devops-cli-extension) installed in [Azure Cloud Shell](https://shell.azure.com/).
- Tenant Management Group Root initialized by selecting **Start Using Management Groups** in the [Azure Portal](https://portal.azure.com/#blade/Microsoft_Azure_ManagementGroups/HierarchyBlade).

```bash
az extensions add --name azure-devops
az devops login
```

or

```bash
az extension update --name azure-devops
```

> If you wish to pin Terraform to a specific version, you can use my [Terraform Container](https://github.com/rjfmachado/containers/tree/master/src/terraform). You'll also need to setup your own registry, Docker Registry service connection, and configure the continuous delivery pipeline accordingly.

## Environments

[] Document target environments and checks

## Configure Management Groups Tenant backfill

Use this process if you have missing subscriptions in your Management Group structure. Wait a few minutes after the API calls and verify the Security Principal for Terraform is assigned rights to subscriptions before applying changes to target subscriptions. I've seen this take a few hours...

```bash
az rest --method post --uri https://management.azure.com/providers/Microsoft.Management/startTenantBackfill?api-version=2018-03-01-preview
az rest --method post --uri https://management.azure.com/providers/Microsoft.Management/tenantBackfillStatus?api-version=2018-03-01-preview
```

## Configure Azure Pipelines

- Install the [Azure Pipelines GitHub Application](https://github.com/apps/azure-pipelines) and authorize the repo to create the service connection in azure devops.
  - TODO: Provide automation - Needs a GH API Key - az devops service-endpoint github create --name test --github-url github.com/rjfmachado

- In Azure Cloud Shell:

```bash
# Prepare your environment
DEVOPS_ACCOUNT='https://dev.azure.com/rjfmachado'
DEVOPS_PROJECT='azuredemos'
az devops configure --defaults organization="$DEVOPS_ACCOUNT"
az devops configure --defaults project="$DEVOPS_PROJECT"

GITHUB_ACCOUNT='rjfmachado'
GITHUB_REPO='azuregovernance'
SC_GITHUB_ID=$(az devops service-endpoint list --query "[?contains(name, '$GITHUB_ACCOUNT')].id" --output tsv)
REPO_AZURE_GOVERNANCE="$GITHUB_ACCOUNT/$GITHUB_REPO"
```

```bash
# Create the CD pipeline
PIPELINE_NAME='azure.governance.cd'
PIPELINE_DESCRIPTION='Azure Governance - Continuous Delivery'
REPO_YAML_PATH='build/cd/azure-pipelines.yml'
FOLDER_PATH='\governance\cd'

az pipelines folder create --path "$FOLDER_PATH"

az pipelines create --name "$PIPELINE_NAME" --description "$PIPELINE_DESCRIPTION" --repository "$REPO_AZURE_GOVERNANCE" --repository-type github --branch master --service-connection "$SC_GITHUB_ID" --yml-path "$REPO_YAML_PATH" --folder-path "$FOLDER_PATH" --skip-first-run
```

```bash
# Create the CI pipeline
PIPELINE_NAME='azure.governance.ci'
PIPELINE_DESCRIPTION='Azure Governance - Pull Request'
REPO_YAML_PATH='build/ci/azure-pipelines.yml'

FOLDER_PATH="\governance\ci"

az pipelines folder create --path "$FOLDER_PATH"


az pipelines create --name "$PIPELINE_NAME" --description "$PIPELINE_DESCRIPTION" --repository "$REPO_AZURE_GOVERNANCE" --repository-type github --branch master --service-connection "$SC_GITHUB_ID" --yml-path "$REPO_YAML_PATH" --folder-path "$FOLDER_PATH" --skip-first-run
```

```bash
# FIXME: Create the Daily validation pipeline - Currently this pipeline is required to be configured manually using the azure devops app, as the oauth method does not carry the event notifications for schedules.
PIPELINE_NAME='azure.governance.validation.daily'
PIPELINE_DESCRIPTION='Azure Governance - Verify deployed environments against expected configuration - Every day at midnight.'
REPO_YAML_PATH='build/ops/azure-pipelines.yml'

FOLDER_PATH="\governance\ops"

az pipelines folder create --path "$FOLDER_PATH"

az pipelines create --name "$PIPELINE_NAME" --description "$PIPELINE_DESCRIPTION" --repository "$REPO_AZURE_GOVERNANCE" --repository-type github --branch master --service-connection "$SC_GITHUB_ID" --yml-path "$REPO_YAML_PATH" --folder-path "$FOLDER_PATH" --skip-first-run
```

> Note: Pipelines are retained for 30 days after deletion. If you are required to rerun the pipeline creation process, you will need to rename your pipelines.

## Stage configuration

- Enable Access management for Azure Resources in [Azure Active Directory Properties](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Properties) for the account executing the below scripts for role assignments at the Tenant Root Management Group.

- In Azure Cloud Shell, select the subscription to store the Terraform Azure Backend storage account.

```bash
az account set --subscription 4c84d56c-f15b-4c6b-ae04-e541dd8d18e8
```

- In Azure Cloud Shell, set the stage name.

```bash
STAGE_NAME='prod'
```

- In Azure Cloud Shell, configure the Service Principal.

```bash
# Configure the service principal
SERVICE_PRINCIPAL_NAME='terraformAzureGovernance'
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
TENANT_ID=$(az account show --query tenantId --output tsv)
CLIENT_SECRET=$(az ad sp create-for-rbac --name "$SERVICE_PRINCIPAL_NAME" --skip-assignment --years 1 --query password --output tsv)
SERVICE_PRINCIPAL_ID=$(az ad sp show --id "http://$SERVICE_PRINCIPAL_NAME" --query appId --output tsv)

# Assign Owner role to Service Principal at the Tenant Root Management Group
az role assignment create --role "Owner" --assignee $SERVICE_PRINCIPAL_ID --scope "/providers/Microsoft.Management/managementGroups/$TENANT_ID"

#TODO: add Service Principal to Azure AD User roles
```

- In Azure Cloud Shell, configure the stage Variable Group.

```bash
# Configure the Variable Group

# TODO: Open GitHub issue to support cross tenant variable-group create with PAT auth. use az login to the tenant connected to Azure DevOps as a workaround.

VARIABLE_GROUP="azuregovernance$STAGE_NAME"
GROUP_ID=$(az pipelines variable-group create --name $VARIABLE_GROUP --authorize false --variables ARM_CLIENT_ID=$SERVICE_PRINCIPAL_ID ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID ARM_TENANT_ID=$TENANT_ID --query id --output tsv)
az pipelines variable-group variable create --group-id $GROUP_ID --name ARM_CLIENT_SECRET --value $CLIENT_SECRET --secret true
```

- In Azure Cloud Shell, configure the terraform backend Resource Group and Storage Account.

```bash
LOCATION="West Europe"
RESOURCE_GROUP_NAME="terraformState"
STORAGE_ACCOUNT_NAME="tfazuregovernance$STAGE_NAME"
CONTAINER_NAME="$STAGE_NAME"

az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
az storage account create --resource-group "$RESOURCE_GROUP_NAME" --name "$STORAGE_ACCOUNT_NAME" --sku Standard_LRS --encryption-services blob --https-only --kind StorageV2
az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT_NAME"

az role assignment create --role "Contributor" --assignee $SERVICE_PRINCIPAL_ID --resource-group "$RESOURCE_GROUP_NAME"

az lock create --name 'preventDelete' --resource-group "$RESOURCE_GROUP_NAME" --lock-type CanNotDelete
```
