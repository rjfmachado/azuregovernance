# Azure Governance with Terraform

[![Build Status](https://dev.azure.com/rjfmachado/azuredemos/_apis/build/status/rjfmachado.azuregovernance?branchName=master)](https://dev.azure.com/rjfmachado/azuredemos/_build/latest?definitionId=20&branchName=master)

This repo contains samples for using Terraform to deploy Azure Governance related resources using Azure Devops and is configured to:

- Support multiple Azure AD Tenants in a multistage pipeline - Currently dev and prod, but designed to support easy addition of more stages.
  - Azure Pipelines YAML templates.
  - Use of containers to support Terraform version pinning.
    - TODO: Add support for Visual Studio Code remote container for terraform dev/debug
- Maintain Terraform state with the azurerm storage account backend.
- Implement Azure Governance Resources
  - Subscription assignment to Management Groups
  - Custom Role Based Access Control definitons scoped to Management Groups
  - TODO:Custom Role Based Access Control definitons scoped to Subscriptions, Resource Groups
  - TODO: Role Based Access Control assignments with builtin and custom roles.
  - TODO: Azure Policy definitions scoped to Management Groups, Subscriptions, Resource Groups
  - TODO: Azure Policy assignments scoped to Management Groups, Subscriptions, Resource Groups
    - TODO: Support for Audit, Deny, Add.
    - TODO: Support for DeployIfNotExists and Managed Service Identities.
- TODO: Add terraform graph and GraphViz support
- TODO: Add Azure DevOps custom dashboard with relevant visuals
- TODO: Improve deployment safety
  - TODO: Added Scheduled plan/verify pipeline (gitops) and notifications
  - TODO: Add pr pipeline to validate/plan in prod (need to test)
  - TODO: Add Stage checks https://docs.microsoft.com/en-us/azure/devops/pipelines/process/checks?view=azure-devops

## Configuration

This repo contains id's and resources used in my own demo/learning environment, fork at will but you'll have to change those.

### Requirements

- [Azure Devops extension for Azure CLI](https://github.com/Azure/azure-devops-cli-extension) installed in [Azure Cloud Shell](https://shell.azure.com/).
- Tenant Management Group Root initialized by selecting **Start Using Management Groups** in the [Azure Portal](https://portal.azure.com/#blade/Microsoft_Azure_ManagementGroups/HierarchyBlade).

```bash
az extensions add --name azure-devops
az devops login
```

> If you wish to pin Terraform to a specific version, you can use my [Terraform Container](https://github.com/rjfmachado/containers/tree/master/src/terraform). You'll also need to setup your own registry, Docker Registry service connection, and configure the continuous delivery pipeline accordingly.

### Configure Azure Pipelines

- Install the [Azure Pipelines GitHub Application](https://github.com/apps/azure-pipelines) and authorize the repo.
- Follow the steps to create the Azure Pipelines Continuous Delivery Pipeline using the yaml definition: build/cd/azure-pipelines.yml.
- TODO: move as much to az cli/automation, following code is failing across tenants, open gh issue

```bash
#DEVOPS_ACCOUNT='https://dev.azure.com/rjfmachado'
#DEVOPS_PROJECT='Azure Platform Engineering'
#az devops configure --defaults organization="$DEVOPS_ACCOUNT"
#az devops configure --defaults project="$DEVOPS_PROJECT"

#CD_BUILD_NAME='governanceManagementGroups - CD'
#CD_BUILD_DESCRIPTION='Deploy Azure Governance'
#REPO_AZURE_GOVERNANCE='rjfmachado/azuregovernance'

#az pipelines create --name "$CD_BUILD_NAME" --description "$CD_BUILD_DESCRIPTION" --repository $REPO_AZURE_GOVERNANCE --branch master --yml-path build/cd/azure-pipelines.yml --service-connection rjfmachado --repository-type github
```

### Stage configuration

TODO: Add more guidance to this step.

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
