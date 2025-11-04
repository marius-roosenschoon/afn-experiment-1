#!/bin/bash
set -euo pipefail

echo "+------------+"
echo "| Smoke test |"
echo "+------------+"

RG="${RG}"
APP="${ACA_APP}"

FQDN="$(az containerapp show -g "$RG" -n "$APP" --query properties.configuration.ingress.fqdn -o tsv)"
if [ -z "${FQDN:-}" ]; then
  echo "##vso[task.logissue type=warning]No ingress FQDN configured."
  exit 0
fi
echo "Testing https://$FQDN ..."
if ! curl -fsS "https://$FQDN/health"; then
  echo "Health endpoint failed; trying root..."
  curl -fsS "https://$FQDN" >/dev/null
fi
echo "Smoke test passed."

echo "----- End -----"
