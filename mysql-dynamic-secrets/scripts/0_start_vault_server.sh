#!/bin/bash


vault server -dev  &


echo "Use new Vault token for dev vault access"
echo "---------------------------------------"
echo ""
echo "export VAULT_TOKEN=$(cat ~/.vault-token)"
