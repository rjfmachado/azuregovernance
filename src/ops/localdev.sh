# dot source this script $ . ../ops/localdev.sh
export TF_VAR_deploymentStage=dev
export TF_IN_AUTOMATION=false
export TF_CLI_ARGS_init="-input=false -backend=true -backend-config=dev.env"
echo "in dev environment"
