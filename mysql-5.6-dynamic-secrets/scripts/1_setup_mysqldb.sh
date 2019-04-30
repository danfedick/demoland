#!/bin/bash

echo "Enter  Mysql Root Password: "
read  MYSQL_ROOT_PASSWORD

echo "Enter  Mysql Database Name: "
read MYSQL_DATABASE

echo "Enter First Mysql Non-Root Admin user: "
read MYSQL_USER

echo "Enter First Mysql Non-Root Password: "
read MYSQL_PASSWORD

echo "Storing Initial Mysql Passwords in Local Development Vault:"
vault kv put secret/mysqldb/ \
  MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  MYSQL_DATABASE=${MYSQL_DATABASE}  \
  MYSQL_USER=${MYSQL_USER} \
  MYSQL_PASSWORD=${MYSQL_PASSWORD}

export MYSQL_ROOT_PASSWORD=$(vault kv get -field=MYSQL_ROOT_PASSWORD secret/mysqldb)
export MYSQL_DATABASE=$(vault kv get -field=MYSQL_DATABASE secret/mysqldb)
export MYSQL_USER=$(vault kv get -field=MYSQL_USER secret/mysqldb)
export MYSQL_PASSWORD=$(vault kv get -field=MYSQL_PASSWORD secret/mysqldb)

cd ../
docker-compose up -d 
