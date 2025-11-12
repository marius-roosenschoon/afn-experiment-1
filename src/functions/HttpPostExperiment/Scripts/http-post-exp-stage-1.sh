#!/bin/bash
set -euo pipefail

echo "+------------------------+"
echo "| Validating Azure login |"
echo "+------------------------+"

az account show

echo "----- End -----"
