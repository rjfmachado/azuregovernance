STAGE_NAME=prod
LOCATION='westeurope'
SUBSCRIPTION_NAME='ricardomachado.net'
KEYVAULT_NAME="azuregovernance"
RG_KEYVAULT_NAME='azuregovernance'

az account set --subscription "$SUBSCRIPTION_NAME"
SUBSCRIPTION_ID=$(az account show --subscription "$SUBSCRIPTION_NAME" --output tsv --query id)
TENANT_ID=$(az account show --subscription "$SUBSCRIPTION_NAME" --query tenantId --output tsv)

# Create the Key Vault
# This vault stores the secret used by Terraform, it is passed to the pipelines by Azure DevOps variable group linking
az group create \
    --name "$RG_KEYVAULT_NAME" \
    --location "$LOCATION" \
    --output none
az keyvault create \
    --name "$KEYVAULT_NAME" \
    --resource-group "$RG_KEYVAULT_NAME"
    --location "$LOCATION" \
    --output none

#Create the Terraform Service Principal and store the values in Key Vault
TF_SERVICE_PRINCIPAL_NAME='tfAzureGovernance'
CLIENT_SECRET_NAME="tfClientSecret"
az keyvault secret set \
    --vault-name "$KEYVAULT_NAME" \
    --name "$CLIENT_SECRET_NAME" \
    --value $(az ad sp create-for-rbac --name "$TF_SERVICE_PRINCIPAL_NAME" --skip-assignment --years 5 --query password --output tsv) \
    --output none

TF_SERVICE_PRINCIPAL_ID=$(az ad sp show --id "http://$TF_SERVICE_PRINCIPAL_NAME" --query appId --output tsv)
#TF_CLIENT_SECRET=$(az keyvault secret show --vault-name $KEYVAULT_NAME --name $CLIENT_SECRET_NAME --query value --output tsv)

# Create Azure Devops Service Connection for Pester tests
SERVICE_CONNECTION_NAME="azureGovernancePester"
export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$(az keyvault secret show --name "$CLIENT_SECRET_NAME" --vault-name "$KEYVAULT_NAME" --query value --output tsv)
az devops service-endpoint azurerm create \
    --azure-rm-service-principal-id $TF_SERVICE_PRINCIPAL_ID \
    --azure-rm-tenant-id $TENANT_ID \
    --azure-rm-subscription-id $SUBSCRIPTION_ID \
    --azure-rm-subscription-name "$SUBSCRIPTION_NAME" \
    --name "$SERVICE_CONNECTION_NAME" \
    --output none

# Assign Owner role to Service Principal at the Tenant Root Management Group
az role assignment create --role "Owner" --assignee $TF_SERVICE_PRINCIPAL_ID --scope "/providers/Microsoft.Management/managementGroups/$TENANT_ID"

# TODO: need Azure AD role assignment

# Create the Terraform Variable Group
VARIABLE_GROUP="azuregovernance$STAGE_NAME"
GROUP_ID=$(az pipelines variable-group create --name $VARIABLE_GROUP --authorize false --variables ARM_CLIENT_ID=$SERVICE_PRINCIPAL_ID ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID ARM_TENANT_ID=$TENANT_ID --query id --output tsv)

# NOTE: use if bypassing keyvault
#az pipelines variable-group variable create --group-id $GROUP_ID --name ARM_CLIENT_SECRET --value $CLIENT_SECRET --secret true


# Create the Terraform Secret Variable Group (Linked to KeyVault)
#VARIABLE_GROUP="azuregovernancesecret$STAGE_NAME"
#GROUP_ID=$(az pipelines variable-group create --name $VARIABLE_GROUP --authorize false --output none)
# TODO: Link the Keyvault to the Variable Group

# Create the Keyvault Reader Service Principal
SERVICE_CONNECTION_NAME="azureGovernanceKeyvaultReader"
KV_READER_SERVICE_PRINCIPAL_NAME='scAzureGovernanceVaultReader'
export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$(az ad sp create-for-rbac --name "$KV_READER_SERVICE_PRINCIPAL_NAME" --skip-assignment --years 1 --query password --output tsv)
KV_SERVICE_PRINCIPAL_ID=$(az ad sp show --id "http://$KV_READER_SERVICE_PRINCIPAL_NAME" --query appId --output tsv)
az devops service-endpoint azurerm create \
    --azure-rm-service-principal-id $KV_SERVICE_PRINCIPAL_ID \
    --azure-rm-tenant-id $TENANT_ID \
    --azure-rm-subscription-id $SUBSCRIPTION_ID \
    --azure-rm-subscription-name "$SUBSCRIPTION_NAME" \
    --name "$SERVICE_CONNECTION_NAME" \
    --output none

# grant access to the vault
az keyvault set-policy --secret-permissions get list --spn $KV_SERVICE_PRINCIPAL_ID --name $KEYVAULT_NAME --output none
az role assignment create --role "Reader" --assignee $KV_SERVICE_PRINCIPAL_ID --resource-group "$RG_KEYVAULT_NAME" --output none

# Configure State Storage Account

RG_STORAGE_NAME="terraformState"
STORAGE_ACCOUNT_NAME="tfazuregovernance$STAGE_NAME"
CONTAINER_NAME="$STAGE_NAME"

az group create --name "$RG_STORAGE_NAME" --location "$LOCATION" --output none
az storage account create --resource-group "$RG_STORAGE_NAME" --name "$STORAGE_ACCOUNT_NAME" --sku Standard_LRS --encryption-services blob --https-only --kind StorageV2 --output none
az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT_NAME" --output none

az role assignment create --role "Contributor" --assignee $TF_SERVICE_PRINCIPAL_ID --resource-group "$RG_STORAGE_NAME" --output none

# TODO: Move the variable groups to no access
# TODO: Authorize the pipelines

az lock create --name 'preventDelete' --resource-group "$RG_STORAGE_NAME" --lock-type CanNotDelete --output none
az lock create --name 'preventDelete' --resource-group "$RG_KEYVAULT_NAME" --lock-type CanNotDelete --output none


