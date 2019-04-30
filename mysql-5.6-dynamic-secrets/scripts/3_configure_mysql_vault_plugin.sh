#!/bin/bash
set -x

export MYSQL_ROOT_PASSWORD=$(vault kv get -field=MYSQL_ROOT_PASSWORD secret/mysqldb)
export MYSQL_DATABASE=$(vault kv get -field=MYSQL_DATABASE secret/mysqldb)
export MYSQL_USER=$(vault kv get -field=MYSQL_USER secret/mysqldb)
export MYSQL_PASSWORD=$(vault kv get -field=MYSQL_PASSWORD secret/mysqldb)
export MYSQL_ROLE=mysql_admin_role
export MYSQL_LEASE=72h
export MYSQL_GRANTS=$(cat ./grants.sql)

echo ""
echo "Creating and naming the Vault Plugin. "
echo "Setting  the connection string for Mysql"
echo "Specifying the associated vault role"
echo "Specifying login credentials::"
echo ""

echo "Creating Mysql Connection:" 
echo "##########################" 
echo ""
cat << EOF 
vault write mysql/config/connection \
    connection_url="root:${MYSQL_ROOT_PASSWORD}@tcp(127.0.0.1:3306)/"

vault write mysql/config/lease \
    lease=72h \
    lease_max=120h

vault write mysql/roles/${MYSQL_ROLE}  \
    sql=${MYSQL_GRANTS}
EOF

vault write mysql/config/connection \
    connection_url="root:${MYSQL_ROOT_PASSWORD}@tcp(127.0.0.1:3306)/"

vault write mysql/config/lease \
    lease=${MYSQL_LEASE} \
    lease_max=120h

vault write mysql/roles/${MYSQL_ROLE} sql="${MYSQL_GRANTS}"
