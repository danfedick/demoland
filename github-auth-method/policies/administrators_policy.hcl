path "sys/*"                                          { policy = "deny" }
path "sys/policy/administrators"                      { capabilities = ["read"] }
