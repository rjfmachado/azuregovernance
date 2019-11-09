# Azure Governance with Terraform

[![Build Status](https://dev.azure.com/rjfmachado/azuredemos/_apis/build/status/governance/cd/azure.governance.cd?branchName=master)](https://dev.azure.com/rjfmachado/azuredemos/_build/latest?definitionId=48&branchName=master)

This repo contains samples for using Terraform to deploy Azure Governance related resources using Azure Devops and is configured to:

- Support multiple Azure AD Tenants in a multistage pipeline - Currently dev and prod, but designed to support easy addition of more stages.
  - Azure Pipelines YAML templates.
  - Use of containers to support Terraform version pinning.
  - //TODO: Add support for Visual Studio Code remote container for terraform dev/debug
- //TODO: Review partner scenarios with multiple customers and Azure Lighthouse/CSP model.
- Maintain Terraform state with the azurerm storage account backend.
- Implement Azure Governance Resources
  - Subscription assignment to Management Groups
    - Support for external management of Subscription Assignment via lifecycle/ignore_changes
  - Custom Role Based Access Control definitons scoped to Management Groups, Subscriptions and Resource Groups.
    - TODO: File GitHub issue as assignments for roles scoped to Management Groups keep getting recreated.
  - Role Based Access Control assignments with builtin and custom roles to Management Groups, Subscriptions and Resource Groups.
  - //TODO: Azure Policy definitions scoped to Management Groups
  - //TODO: Azure Policy assignments to Management Groups
    - //TODO: <https://github.com/terraform-providers/terraform-provider-azurerm/issues/3762>
    - //TODO: Support for Audit, Deny, Add, Modify (Tags)
    - //TODO: Support for DeployIfNotExists and Managed Service Identities.
  - //TODO: Add Blueprints definitions/assignments
- //TODO: Add terraform graph and GraphViz support, review terraform-docs
- //TODO: Add Azure DevOps custom dashboard with relevant visuals
- //TODO: Add azure dashboard <https://www.terraform.io/docs/providers/azurerm/r/dashboard.html>
- //TODO: Improve deployment safety
  - Added Scheduled plan pipeline (gitops) and notifications
  - PR pipeline to validate/plan in dev/prod
    - //TODO: Pipeline not running on schedule, verify - issue with OAUTH and GitHub triggers
  - //TODO: Add tflint, investigate terratest
  - //TODO: Add tests to PR builds
  - //TODO: Add Environments,Stage checks <https://docs.microsoft.com/en-us/azure/devops/pipelines/process/checks?view=azure-devops>
    <https://github.com/microsoft/azure-pipelines-yaml/issues/288>
- //TODO: Add Security Center configuration
- //TODO: Add Azure Monitor
- //TODO: Review repo badges, eg <https://raw.githubusercontent.com/wata727/tflint/master/README.md>
- //TODO: seriously improve this guidance :)
- //TODO: Monitor secret age and alert.
- //TODO: Azure AD Roles
  - <https://techcommunity.microsoft.com/t5/Azure-Active-Directory-Identity/Custom-roles-for-app-registration-management-is-now-in-public/ba-p/789101>
  - <https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/roles-custom-available-permissions>
  - <https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/roles-custom-overview>
  - //TODO: GA of Azure AD Roles (Global Reader)<https://techcommunity.microsoft.com/t5/Azure-Active-Directory-Identity/16-new-built-in-roles-including-Global-reader-now-available-in/ba-p/900749>
  - //TODO:Custom Roles for App registration
- //TODO: Action Groups/Alerts
- //TODO: Add a provisioners/connections scenario
- //TODO: Connect Activity Log to Workspace
- //TODO: Connect Azure AD Logs
- //TODO: Verify usage of *dynamic* block
- //TODO: investigate CNAB bundle as a release tool?
- //TODO: move my vars to samples
- //TODO: add guidance for local development

## Configuration

This repo contains id's and resources used in my own demo/learning environment, fork at will but you'll have to change those.

### Requirements

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

### Environments

//TODO: Document environments and checks

Configure Management Groups Tenant backfill.

>Use this process if you have missing subscriptions in your Management Group structure. Wait a few minutes after the API calls and verify the Security Principal for Terraform is assigned rights to subscriptions before applying changes to target subscriptions. I've seen this take a few hours...

```bash
az rest --method post --uri https://management.azure.com/providers/Microsoft.Management/startTenantBackfill?api-version=2018-03-01-preview
az rest --method post --uri https://management.azure.com/providers/Microsoft.Management/tenantBackfillStatus?api-version=2018-03-01-preview
```

### Configure Azure Pipelines

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

### Stage configuration

```bash
SUBSCRIPTION_NAME='grgerg'
KEYVAULT_NAME="bf9834j683"
LOCATION='West Europe'
RG_KEYVAULT_NAME='498tjfy384j2yt'

# Create the vault
az account set --subscription $(az account show --subscription "$SUBSCRIPTION_NAME" --query id --output tsv)
az group create --name "$RG_KEYVAULT_NAME" --location "$LOCATION"
az keyvault create --name "$KEYVAULT_NAME" --location "$LOCATION" --sku standard --enabled-for-template-deployment --enabled-for-deployment --enabled-for-disk-encryption --resource-group "$RG_KEYVAULT_NAME"

#Create the Service Principal and store in Key Vault

SERVICE_PRINCIPAL_NAME='spName'

SUBSCRIPTION_ID=$(az account show --subscription "$SUBSCRIPTION_NAME" --query id --output tsv)
TENANT_ID=$(az account show --subscription "$SUBSCRIPTION_NAME" --query tenantId --output tsv)

SECRET_NAME="secretName"

az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "$SECRET_NAME" --value $(az ad sp create-for-rbac --name "$SERVICE_PRINCIPAL_NAME" --skip-assignment --years 5 --query password --output tsv)
SERVICE_PRINCIPAL_ID=$(az ad sp show --id "http://$SERVICE_PRINCIPAL_NAME" --query appId --output tsv)

SERVICE_ENDPOINT_NAME="serviceEndpointName"

export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$(az keyvault secret show --name "$SECRET_NAME" --vault-name "$KEYVAULT_NAME" --query value --output tsv)

az devops service-endpoint azurerm create --azure-rm-service-principal-id $SERVICE_PRINCIPAL_ID --azure-rm-tenant-id $TENANT_ID --azure-rm-subscription-id $SUBSCRIPTION_ID --azure-rm-subscription-name "$SUBSCRIPTION_NAME" --name "$SERVICE_ENDPOINT_NAME"
```

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
