#!/bin/bash
#set -x

export MYSQL_ROOT_PASSWORD=$(vault kv get -field=MYSQL_ROOT_PASSWORD secret/mysqldb)
export MYSQL_DATABASE=$(vault kv get -field=MYSQL_DATABASE secret/mysqldb)
export MYSQL_USER=$(vault kv get -field=MYSQL_USER secret/mysqldb)
export MYSQL_PASSWORD=$(vault kv get -field=MYSQL_PASSWORD secret/mysqldb)
export MYSQL_ROLE=mysql_admin_role

echo ""
echo "Creating and naming the Vault Plugin. "
echo "Setting  the connection string for Mysql"
echo "Specifying the associated vault role"
echo "Specifying login credentials::"
echo ""
echo "vault write database/config/mysql-admin-role \ "
echo "  plugin_name=mysql-database-plugin \ "
echo "  connection_url='{{username}}:{{password}}@tcp(127.0.0.1:3306)/' \ "
echo "  allowed_roles='${MYSQL_ROLE}' \ "
echo "  username='root' \ "
echo "  password='\${MYSQL_ROOT_PASSWORD}' "
echo ""

vault write database/config/${MYSQL_DATABASE} plugin_name=mysql-database-plugin \
  connection_url="{{username}}:{{password}}@tcp(127.0.0.1:3306)/" \
  allowed_roles="${MYSQL_ROLE}" \
  username="root" \
  password="${MYSQL_ROOT_PASSWORD}"
