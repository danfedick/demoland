#!/bin/bash
#set -x

echo -n "What user are you adding access to?: "
read USERNAME

echo -n "What group are you adding access to?: "
read GROUPNAME

#Create Policy File:
cat << EOF > ../policies/${USERNAME}_policy.hcl
path "sys/*"                                          { policy = "deny" }
path "sys/policy/${USERNAME}"                             { capabilities = ["read"] }
EOF

# Write User policy to Vault: 
vault policy write ${USERNAME} ../policies/${USERNAME}_policy.hcl
vault policy read ${USERNAME}


# Write Group policy: 
cat << EOF > ../policies/${GROUPNAME}_policy.hcl
path "sys/*"                                          { policy = "deny" }
path "sys/policy/${GROUPNAME}"                      { capabilities = ["read"] }
EOF

# Write Groups policy to Vault: 
vault policy write ${GROUPNAME} ../policies/${GROUPNAME}_policy.hcl
vault policy read ${GROUPNAME}
