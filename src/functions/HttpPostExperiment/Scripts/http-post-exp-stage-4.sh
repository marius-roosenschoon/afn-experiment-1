#!/bin/bash
set -euo pipefail

echo "+---------------------------+"
echo "| Ensure ingress is enabled |"
echo "+---------------------------+"

RG="${RG}"
FUNCTION_APP_NAME="${FUNCTION_APP_NAME}"

echo "Enabling ingress for app $FUNCTION_APP_NAME"
az containerapp ingress enable \
  --resource-group "$RG" \
  --name "$FUNCTION_APP_NAME" \
  --type external \
  --target-port 80

echo "----- End -----"
