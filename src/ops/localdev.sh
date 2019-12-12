# dot source this script $ . ./localdev.sh
# TODO: verify the tenant/subscription
export TF_VAR_deploymentStage=dev
export TF_IN_AUTOMATION=false
export TF_CLI_ARGS_init="-input=false -backend=true -backend-config=dev.env"
echo "in dev environment"
