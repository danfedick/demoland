path "sys/*"                              { policy = "deny" }
path "sys/policies/acl/the_fed"     { capabilities = ["read"] }
path "mysql/creds/mysql_admin_role"       { capabilities =  ["create", "read", "update", "delete", "list", "sudo"] }
