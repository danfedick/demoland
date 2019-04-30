path "sys/*"                              { policy = "deny" }
path "sys/policies/acl/the_fed"     { capabilities = ["read"] }
path "database/creds/mysql_admin_role"       { capabilities =  ["create", "read", "update", "delete", "list", "sudo"] }
