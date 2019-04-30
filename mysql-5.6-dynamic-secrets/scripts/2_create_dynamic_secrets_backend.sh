#!/bin/bash

# Go to the secrets backend for vault
# Remove the database path: 
rm -Rf ~/vault-backend/sys/expire/id/database


# Disable Database Secrets Backend 
vault secrets disable  mysql

#List all Secrets: 
echo "List of Vault Backends"
echo ""
echo " # vault secrets list "
echo ""
vault secrets list







state=$(vault secrets list | grep mysql/ &>/dev/null ; echo $?)

if [[ ${state} == 0 ]]
then
  echo "The database secrets engine is already enabled"
  vault secrets list
  exit 1
else
  echo ""
  echo "vault secrets enable database"
  echo ""
  vault secrets enable mysql
fi


echo ""

echo "List of Secrets Backends"

echo ""

vault secrets list
