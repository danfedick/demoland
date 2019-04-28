#!/bin/bash

export VAULT_TOKEN=$(cat ~/.vault-token)
export VAULT_ADDR=http://127.0.0.1:8200

export MYSQL_ROOT_PASSWORD=$(vault kv get -field=MYSQL_ROOT_PASSWORD secret/mysqldb)
export MYSQL_DATABASE=$(vault kv get -field=MYSQL_DATABASE secret/mysqldb)

export MYSQL_USER=the_fed
export MYSQL_PASSWORD=$(vault kv get -field=MYSQL_PASSWORD secret/mysqldb)
export MYSQL_ROLE=mysql_admin_role



cat << EOF > ./policies/${MYSQL_USER}.hcl
path "sys/*"                              { policy = "deny" }
path "sys/policy/dfedick"                 { capabilities = ["read"] }
path "database/creds/${MYSQL_ROLE}"       { capabilities =  ["create", "read", "update", "delete", "list", "sudo"] }
EOF

vault policy write ${MYSQL_USER} ../policies/${MYSQL_USER}.hcl
vault token create -policy=${MYSQL_USER}
