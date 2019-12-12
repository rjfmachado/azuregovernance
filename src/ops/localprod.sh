# dot source this script $ . ./localprod.sh
# TODO: verify the tenant/subscription
export TF_VAR_deploymentStage=prod
export TF_IN_AUTOMATION=false
export TF_CLI_ARGS_init="-input=false -backend=true -backend-config=prod.env"
echo "in prod environment"
