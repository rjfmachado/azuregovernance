# dot source this script $ . ./localprod.sh

rm .terraform/ -rf

export TF_VAR_deploymentStage=prod
export TF_IN_AUTOMATION=false
export TF_CLI_ARGS_init="-input=false -backend=true -backend-config=prod.stage"

if az account set --subscription "ricardomachado.net";
then
    echo "in prod environment, please ensure the correct branch is selected:"
    git branch
else
    echo "failed to select the correct subscription, please run az login."
fi
