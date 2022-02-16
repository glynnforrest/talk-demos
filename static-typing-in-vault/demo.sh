#!/bin/bash

. demo-magic.sh
TYPE_SPEED=40

clear

############
# Overview #
############
pei "./vault-helper.py -h"

pe "bat rules.json"
clear

############
# Validate #
############
pei "./vault-helper.py validate -h"
pei "./vault-helper.py validate-path -h"
wait
clear

pe "./vault-helper.py validate secret/production/selfie/s3-creds"
echo '$'
echo "http://localhost:8200/ui/vault/secrets/secret/show/production/selfie/s3-creds"
# Edit the secret in the UI to make it invalid
p "!!"
./vault-helper.py validate secret/production/selfie/s3-creds

pe "./vault-helper.py validate secret/complex"
echo '$'
echo "http://localhost:8200/ui/vault/secrets/secret/show/complex"
# Edit the secret in the UI to make it invalid
p "!!"
./vault-helper.py validate secret/complex

wait
clear

pe "./vault-helper.py validate-path secret/production/backoffice"
pe "vault kv put secret/production/backoffice/secret value=test"
pe "./vault-helper.py validate-path secret/production/backoffice"
pe "./vault-helper.py validate-path secret/production/backoffice --ignore-missing-rule"
pe "vault kv delete secret/production/backoffice/secret"

wait
clear

pe "./vault-helper.py validate-path secret/staging"
echo '$'
echo "http://localhost:8200/ui/vault/secrets/secret/list/staging"
# Open the UI to see why the staging secrets are invalid

pe "./vault-helper.py validate-path secret"

wait
clear


#########
# Write #
#########

pe "./vault-helper.py write -h"
wait
clear

pe "./vault-helper.py write secret/staging/selfie/s3-creds"
pe "vault kv get secret/staging/selfie/s3-creds"
pe "./vault-helper.py validate secret/staging/selfie/s3-creds"

wait
clear

############
# Describe #
############
pei "./vault-helper.py describe -h"
pei "./vault-helper.py describe-path -h"
wait
clear

pe "./vault-helper.py describe s3-creds"
wait
clear

pe "./vault-helper.py describe-path secret/prod/selfie/s3-creds"
pe "./vault-helper.py describe-path secret/production/selfie/s3-creds"
wait
clear

pe "./vault-helper.py describe --format json s3-creds"
wait
clear

pe "jq '.rules[2]' < rules.json"
pe "./vault-helper.py describe encryption-key"
