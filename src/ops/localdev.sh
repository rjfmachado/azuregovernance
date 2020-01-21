# dot source this script $ . ./localdev.sh

rm .terraform/ -rf

export TF_VAR_deploymentStage=dev
export TF_IN_AUTOMATION=false
export TF_CLI_ARGS_init="-input=false -backend=true -backend-config=dev.stage"

if az account set --subscription "ricardomachado.net (DEV)";
then
    echo "in dev environment, please ensure the correct branch is selected:"
    git branch
else
    echo "failed to select the correct subscription, please run az login."
fi