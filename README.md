# Azure Governance with Terraform

[![Build Status](https://dev.azure.com/rjfmachado/azuredemos/_apis/build/status/rjfmachado.azuregovernance.ci?branchName=master)](https://dev.azure.com/rjfmachado/azuredemos/_build/latest?definitionId=32&branchName=master)

This repo contains samples for using Terraform to deploy Azure Governance related resources using Azure Devops and is configured to:

- Support multiple Azure AD Tenants in a multistage pipeline - Currently dev and prod, but designed to support easy addition of more stages.
  - Azure Pipelines YAML templates.
  - Use of containers to support Terraform version pinning.
    - TODO: Add support for Visual Studio Code remote container for terraform dev/debug
- Maintain Terraform state with the azurerm storage account backend.
- Implement Azure Governance Resources
  - Subscription assignment to Management Groups
  - Custom Role Based Access Control definitons scoped to Management Groups
    - TODO: File GitHub issue as assignment keeps getting recreated
  - TODO:Custom Role Based Access Control definitons scoped to Subscriptions, Resource Groups
  - TODO: Role Based Access Control assignments with builtin and custom roles.
  - TODO: Azure Policy definitions scoped to Management Groups, Subscriptions, Resource Groups
  - TODO: Azure Policy assignments scoped to Management Groups, Subscriptions, Resource Groups
    - TODO: Support for Audit, Deny, Add.
    - TODO: Support for DeployIfNotExists and Managed Service Identities.
  - TODO: Add Blueprints definitions/assignments
- TODO: Add terraform graph and GraphViz support
- TODO: Add Azure DevOps custom dashboard with relevant visuals
- TODO: Improve deployment safety
  - Added Scheduled plan pipeline (gitops) and notifications
  - PR pipeline to validate/plan in dev/prod
    - TODO: Pipeline not running on schedule, verify
  - TODO: Add tflint, investigate terratest
  - TODO: Add tests to PR builds
  - TODO: Add Stage checks https://docs.microsoft.com/en-us/azure/devops/pipelines/process/checks?view=azure-devops
  -TODO: Rename PR build in Azure DevOps or respect name: in YAML.
- Add Security Center configuration
- Add Azure Monitor
- TODO: Review repo badges, eg https://raw.githubusercontent.com/wata727/tflint/master/README.md
- TODO: seriously improve this guidance :)
- TODO: Monitor secret age and alert.
- Azure AD Roles
  - <https://techcommunity.microsoft.com/t5/Azure-Active-Directory-Identity/Custom-roles-for-app-registration-management-is-now-in-public/ba-p/789101>
  - <https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/roles-custom-available-permissions>
  - <https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/roles-custom-overview>

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

### Environments

TODO: Document environments and checks

### Configure Azure Pipelines

- Install the [Azure Pipelines GitHub Application](https://github.com/apps/azure-pipelines) and authorize the repo to create the service connection in azure devops.
  - TODO: Needs a GH API Key - az devops service-endpoint github create --name test --github-url github.com/rjfmachado

> Note: Pipelines are retained for 30 days after deletion. If you are required to rerun the pipeline creation process, you will need to rename your pipelines.

```bash
DEVOPS_ACCOUNT='https://dev.azure.com/rjfmachado'
DEVOPS_PROJECT='azuredemos'
az devops configure --defaults organization="$DEVOPS_ACCOUNT"
az devops configure --defaults project="$DEVOPS_PROJECT"

# TODO: Need to move this to a query az devops service-connection list
SC_GITHUB_ID='cb07f904-3076-4d67-8ffd-efceab6f21a8'
REPO_AZURE_GOVERNANCE='rjfmachado/azuregovernance'

PIPELINE_NAME='rjfmachado.azuregovernance.ci'
PIPELINE_DESCRIPTION='Azure Governance - Continuous Integration pipeline.'
REPO_YAML_PATH='build/ci/azure-pipelines.yml'

az pipelines create --name "$PIPELINE_NAME" --description "$PIPELINE_DESCRIPTION" --repository "$REPO_AZURE_GOVERNANCE" --repository-type github --branch master --service-connection "$SC_GITHUB_ID" --yml-path "$REPO_YAML_PATH" --skip-first-run

PIPELINE_NAME='rjfmachado.azuregovernance.pr'
PIPELINE_DESCRIPTION='Azure Governance - Pull Request validation pipeline.'
REPO_YAML_PATH='build/pr/azure-pipelines.yml'

az pipelines create --name "$PIPELINE_NAME" --description "$PIPELINE_DESCRIPTION" --repository "$REPO_AZURE_GOVERNANCE" --repository-type github --branch master --service-connection "$SC_GITHUB_ID" --yml-path "$REPO_YAML_PATH" --skip-first-run

PIPELINE_NAME='rjfmachado.azuregovernance.ops'
PIPELINE_DESCRIPTION='Azure Governance - Verify deployed environments against expected configuration - Every day at midnight.'
REPO_YAML_PATH='build/ops/azure-pipelines.yml'

az pipelines create --name "$PIPELINE_NAME" --description "$PIPELINE_DESCRIPTION" --repository "$REPO_AZURE_GOVERNANCE" --repository-type github --branch master --service-connection "$SC_GITHUB_ID" --yml-path "$REPO_YAML_PATH" --skip-first-run

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
#TODO: add Service Principal to Azure AD User administrator role
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
