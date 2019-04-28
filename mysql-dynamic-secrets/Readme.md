# Vault Mysql Dynamic Secrets 
Vault is an encrypted password key/value store  for programmatic access to user and password information.  The following is a demo of the Vault Database Dynamic Secrets feature in  Vault.  

#### Start Local Vault Server
First: Start Vault (in development mode) and  Mysql on your local environment.  

*(This demo is built specifically on a Mac OS operating system but can be modified for Linux.)*
```
$ cd demoland/srcripts
$ ./0_start_vault_server.sh

==> Vault server configuration:

             Api Address: http://127.0.0.1:8200
                     Cgo: disabled
         Cluster Address: https://127.0.0.1:8201
              Listener 1: tcp (addr: "127.0.0.1:8200", cluster address: "127.0.0.1:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
               Log Level: (not set)
                   Mlock: supported: false, enabled: false
                 Storage: inmem
                 Version: Vault v0.11.5
             Version Sha: a59ffa4a0f09bbf198241fe6793a96722789b639

WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and starts unsealed with a single unseal key. The root token is already
authenticated to the CLI, so you can immediately begin using Vault.

You may need to set the following environment variable:

    $ export VAULT_ADDR='http://127.0.0.1:8200'

The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.

Unseal Key: 7NsENUL3bir0rYKMD2DJxYjDZ2+/EywVNjolfwkNA5s=
Root Token: 5i8Xbbej6I1C6YAKoZipVRhp

Development mode should NOT be used in production installations!

==> Vault server started! Log data will stream in below:
```

Once Vault is started, set your `VAULT_TOKEN` environment variable.  

*(Note, starting the Vault Server in -dev mode automatically drops a token into your ~/.vault-token file locally.)* 
```
export VAULT_TOKEN=$(cat ~/.vault-token)
```

#### Start Local Mysql DB Server
This step will ask you a few questions about your root password, database name and new non-root user/password.  All this information will be stored in Static creds path for programmatic use to configure Vault dynamic secrets.

```
./1_setup_mysqldb.sh
Enter  Mysql Root Password:
VX7hixhQWiH5xOIdTQqcZRa
Enter  Mysql Database Name:
the_big_labowski
Enter First Mysql Non-Root Admin user:
the_fed
Enter First Mysql Non-Root Password:
EjE4GJ895Hh7JMP2RlRdpVl
Storing Initial Mysql Passwords in Local Development Vault:
Key              Value
---              -----
created_time     2019-04-28T01:11:25.589224Z
deletion_time    n/a
destroyed        false
version          1
Creating network "mysql-dynamic-secrets_default" with the default driver
Creating volume "mysql-dynamic-secrets_db_data" with default driver
Creating mysqldb ... done


$ > docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
21ea9c2b0053        mysql:5.7           "docker-entrypoint.s…"   7 seconds ago       Up 5 seconds        0.0.0.0:3306->3306/tcp, 33060/tcp   mysqldb
```

#### Login to Mysql: 
There is a functions file in `demoland/mysql-dynamic-secrets` to source that has some helper scripts.  Source the `functions` file and then run the list_functions function:

```
$ > cd demoland/mysql-dynamic-secrets/
$ > . functions
$ > list_functions

Available Functions in your Shell are:
#######################################
get_static_creds
get_dynamic_creds
connect_static
set_vault_token
```

Run the `get_static_creds` function:
```
$ > get_static_creds
Static Credentials for Mysql are are gotten and available for the following vars:
MYSQL_ROOT_PASSWORD: VX7hixhQWiH5xOIdTQqcZRa
MYSQL_DATABASE: the_big_labowski
MYSQL_USER: the_fed
MYSQL_PASSWORD: EjE4GJ895Hh7JMP2RlRdpVl
```

#### Login to the Mysql Database: 
Use the `connect_static` helper function:

```
$ > connect_static

mysql -u root -h 127.0.0.1 -p<passwd>

**Using the mysql static passwd retrieved from vault'**

mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.24 MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```
#### Show Users:

```
mysql> select user from mysql.user;
+---------------+
| user          |
+---------------+
| root          |
| the_fed       |
| mysql.session |
| mysql.sys     |
| root          |
+---------------+
5 rows in set (0.00 sec)
> exit
 bye
```

#### Create the Database secrets backend:
```$ > ./2_create_dynamic_secrets_backend.sh
Success! Disabled the secrets engine (if it existed) at: database/
List of Vault Backends

 # vault secrets list

Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_a01b5ea4    per-token private secret storage
identity/     identity     identity_52a10e47     identity store
secret/       kv           kv_2627f6b0           key/value secret storage
sys/          system       system_34dab7f2       system endpoints used for control, policy and debugging

vault secrets enable database

2019-04-27T21:22:14.973-0400 [INFO]  core: successful mount: namespace= path=database/ type=database
Success! Enabled the database secrets engine at: database/

List of Secrets Backends

Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_a01b5ea4    per-token private secret storage
database/     database     database_f85fe9b2     n/a
identity/     identity     identity_52a10e47     identity store
secret/       kv           kv_2627f6b0           key/value secret storage
sys/          system       system_34dab7f2       system endpoints used for control, policy and debugging```
```

#### Configure the Mysql / Vault Plugin: 
```
$ > ./3_configure_mysql_vault_plugin.sh

Creating and naming the Vault Plugin.
Setting  the connection string for Mysql
Specifying the associated vault role
Specifying login credentials::

vault write database/config/mysql-admin-role \
  plugin_name=mysql-database-plugin \
  connection_url='{{username}}:{{password}}@tcp(127.0.0.1:3306)/' \
  allowed_roles='mysql_admin_role' \
  username='root' \
  password='${MYSQL_ROOT_PASSWORD}'
  ```

####  Configure the Vault Role:
```
$ > ./4_configure_vault_role.sh
Create Vault Database Role:
Add the Mysql Database Creation Statement with variables for user/password:
Add User Grants for the role
Assigning a default_ttl (Lease Duration)
Assigning a max_ttl (Lease Duration)
 vault write database/roles/mysql_admin_role \
   db_name=the_big_labowski \
   creation_statements="CREATE USER {{name}}@% IDENTIFIED BY {{password}};" \
   GRANT USAGE ON *.* TO '{{name}}'@'%';  \
   GRANT ALL PRIVILEGES ON `the_big_labowski`.* to '{{name}}'@'%'; \
   default_ttl=1h \
   max_ttl=24h
Success! Data written to: database/roles/mysql_admin_role
```


#### Get Dynamic Credentials from Vault: 
```
$ > get_dynamic_creds

vault read database/creds/mysql_admin_role

WARNING! The following warnings were returned from Vault:

  * TTL of "10h0m0s" exceeded the effective max_ttl of "24m0s"; TTL value is
  capped accordingly

Key                Value
---                -----
lease_id           database/creds/mysql_admin_role/12TSyV2Hxha6cIsGKmHLXH4R
lease_duration     24m
lease_renewable    true
password           A1a-2OuWMRuOZ0xz7l3B
username           v-root-mysql_admi-797YwU08qM1pqY
```

#### Login using Dynamic Secret 

```
$ > mysql -h 127.0.0.1 -u v-root-mysql_admi-797YwU08qM1pqY -pA1a-2OuWMRuOZ0xz7l3B
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.7.24 MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| the_big_labowski   |
+--------------------+
2 rows in set (0.00 sec)

mysql> show grants;
+----------------------------------------------------------------------------------------+
| Grants for v-root-mysql_admi-797YwU08qM1pqY@%                                          |
+----------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'v-root-mysql_admi-797YwU08qM1pqY'@'%'                           |
| GRANT ALL PRIVILEGES ON `the_big_labowski`.* TO 'v-root-mysql_admi-797YwU08qM1pqY'@'%' |
+----------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> exit
bye
```

#### Log out and log back in as root
  Take a look at the `mysql.user` table.  

```
$ > connect_static

mysql -u root -h 127.0.0.1 -p'Using the mysql static passwd retrieved from vault'

mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 6
Server version: 5.7.24 MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> select user from mysql.user;
+----------------------------------+
| user                             |
+----------------------------------+
| root                             |
| the_fed                          |
| v-root-mysql_admi-797YwU08qM1pqY |
| mysql.session                    |
| mysql.sys                        |
| root                             |
+----------------------------------+
6 rows in set (0.01 sec)
```



Awesome!  You did it!  Now, let's clean up.  

```
$ > ./6_cleanup_demo.sh
Stopping mysqldb ... done
Removing mysqldb ... done
Removing network mysql-dynamic-secrets_default
Removing volume mysql-dynamic-secrets_db_data
==> Vault shutdown triggered
2019-04-27T21:31:43.042-0400 [INFO]  core: marked as sealed
2019-04-27T21:31:43.042-0400 [INFO]  core: pre-seal teardown starting
2019-04-27T21:31:43.042-0400 [INFO]  core: stopping cluster listeners
2019-04-27T21:31:43.042-0400 [INFO]  core: shutting down forwarding rpc listeners
2019-04-27T21:31:43.042-0400 [INFO]  core: forwarding rpc listeners stopped


$ > docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```
 The Mysql database and Vault Dev server are now cleaned up and destroyed. 