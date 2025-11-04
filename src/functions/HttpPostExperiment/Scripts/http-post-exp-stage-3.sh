#!/bin/bash
set -euo pipefail

echo "+---------------------------------------------------+"
echo "| Verifying deployment and getting function app URL |"
echo "+---------------------------------------------------+"

RG="${RG}"
FUNCTION_APP_NAME="${FUNCTION_APP_NAME}"

az functionapp show --name $FUNCTION_APP_NAME --resource-group $RG --query "defaultHostName" -o tsv
az functionapp function list --name $FUNCTION_APP_NAME --resource-group $RG --query "[].name" -o tsv

echo "----- End -----"
