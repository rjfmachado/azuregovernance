# dot source this script $ . ../ops/localprod.sh

echo "in prod environment"

export TF_VAR_deploymentStage=prod

export ARM_CLIENT_ID="$(az pipelines variable-group list --output json --query "[?name=='azuregovernanceprod'].{variables:variables.ARM_CLIENT_ID.value}" --output tsv)"
export ARM_SUBSCRIPTION_ID="$(az pipelines variable-group list --output json --query "[?name=='azuregovernanceprod'].{variables:variables.ARM_SUBSCRIPTION_ID.value}" --output tsv)"
export ARM_TENANT_ID="$(az pipelines variable-group list --output json --query "[?name=='azuregovernanceprod'].{variables:variables.ARM_TENANT_ID.value}" --output tsv)"
export ARM_CLIENT_SECRET="$(az keyvault secret show --vault-name azuregovernance --name tfClientSecret --query value --output tsv)"

export TF_IN_AUTOMATION=false

export TF_CLI_ARGS_init="-input=false -backend=true -backend-config=prod.env"