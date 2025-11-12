#!/bin/bash
set -euo pipefail

echo "+------------------------------+"
echo "| Deploying to Azure Functions |"
echo "+------------------------------+"

RG="${RG}"
FUNCTION_APP_NAME="${FUNCTION_APP_NAME}"
PACKAGE_PATH="${PACKAGE_PATH}"

az functionapp deployment source config-zip --resource-group $RG --name $FUNCTION_APP_NAME --src $PACKAGE_PATH


echo "----- End -----"
