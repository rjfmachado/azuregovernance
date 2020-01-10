# dot source this script $ . ./localdev.sh
# TODO: verify the tenant/subscription
rm .terraform/ -rf
az account set --subscription "ricardomachado.net (DEV)"
export TF_VAR_deploymentStage=dev
export TF_IN_AUTOMATION=false
export TF_CLI_ARGS_init="-input=false -backend=true -backend-config=dev.stage"
echo "in dev environment"
