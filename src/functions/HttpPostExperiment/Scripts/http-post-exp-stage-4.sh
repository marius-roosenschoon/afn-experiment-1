#!/bin/bash
set -euo pipefail

echo "+---------------------------+"
echo "| Ensure ingress is enabled |"
echo "+---------------------------+"

RG="${RG}"
APP="${ACA_APP}"

echo "Enabling ingress for app $APP"
az containerapp ingress enable \
  --resource-group "$RG" \
  --name "$APP" \
  --type external \
  --target-port 80

echo "----- End -----"
