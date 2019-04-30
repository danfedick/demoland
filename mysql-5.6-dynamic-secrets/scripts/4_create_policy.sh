#!/bin/bash

export VAULT_TOKEN=$(cat ~/.vault-token)
export VAULT_ADDR=http://127.0.0.1:8200

export MYSQL_USER=$(vault kv get -field=MYSQL_USER secret/mysqldb)
export MYSQL_ROLE=mysql_admin_role



cat << EOF > ../policies/${MYSQL_USER}.hcl
path "sys/*"                              { policy = "deny" }
path "sys/policies/acl/${MYSQL_USER}"     { capabilities = ["read"] }
path "mysql/creds/${MYSQL_ROLE}"       { capabilities =  ["create", "read", "update", "delete", "list", "sudo"] }
EOF

vault policy write ${MYSQL_USER} ../policies/${MYSQL_USER}.hcl
token=$(vault token create -format=json -policy="${MYSQL_USER}" -display-name="${MYSQL_USER}" | jq -r .auth.client_token)

cp ~/.vault-token ~/.vault-token-root
echo ${token} > ~/.vault-token 
