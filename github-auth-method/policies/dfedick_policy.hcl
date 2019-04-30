path "sys/*"                                          { policy = "deny" }
path "sys/policy/dfedick"                             { capabilities = ["read"] }
path "sys/policies/acl/dfedick"                       { capabilities = ["read"] }
path "secret/users/dfedick/supersecretkey"            { capabilities = ["read","list"] }
