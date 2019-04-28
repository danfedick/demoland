#!/bin/bash
#set -x

export VAULT_TOKEN=$(cat ~/.vault-token)
export VAULT_ADDR=http://127.0.0.1:8200

export MYSQL_ROOT_PASSWORD=$(vault kv get -field=MYSQL_ROOT_PASSWORD secret/mysqldb)
export MYSQL_DATABASE=$(vault kv get -field=MYSQL_DATABASE secret/mysqldb)
export MYSQL_USER=$(vault kv get -field=MYSQL_USER secret/mysqldb)
export MYSQL_PASSWORD=$(vault kv get -field=MYSQL_PASSWORD secret/mysqldb)
export MYSQL_ROLE=mysql_admin_role


echo "Create Vault Database Role: " 
echo "Add the Mysql Database Creation Statement with variables for user/password:"
echo "Add User Grants for the role"
echo "Assigning a default_ttl (Lease Duration)"
echo "Assigning a max_ttl (Lease Duration)"

echo " vault write database/roles/${MYSQL_ROLE} \ "
echo "   db_name=${MYSQL_DATABASE} \ "
echo '   creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';" \  '
echo "   GRANT USAGE ON *.* TO '{{name}}'@'%';  \ " 
echo "   GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* to '{{name}}'@'%'; \ " 
echo "   default_ttl="1h" \ "
echo "   max_ttl="24h" "


vault write database/roles/${MYSQL_ROLE} \
    db_name=${MYSQL_DATABASE} \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT USAGE ON ${MYSQL_DATABASE}.* TO '{{name}}'@'%';   GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* to '{{name}}'@'%'; " \
    default_ttl="10h" \
    max_ttl="24m"

