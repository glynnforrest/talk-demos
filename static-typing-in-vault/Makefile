.PHONY: run
run:
	docker run -ti --rm --name vault -p 8200:8200 hashicorp/vault

.PHONY: secrets
secrets:
	vault secrets disable secret/
	vault secrets enable -path secret -version 1 kv

	vault kv put secret/simple user=admin password=hunter2
	vault kv put secret/typed @secrets/typed.json
	vault kv put secret/complex @secrets/complex.json

	vault kv put secret/production/selfie/s3-creds @secrets/selfie-production-s3-creds.json

	vault kv put secret/production/backoffice/s3-creds @secrets/backoffice-production-s3-creds.json
	vault kv put secret/production/backoffice/api-creds @secrets/backoffice-production-api-creds.json
	vault kv put secret/production/backoffice/encryption-key @secrets/backoffice-production-encryption-key.json
	vault kv put secret/staging/backoffice/s3-creds @secrets/backoffice-staging-s3-creds.json
	vault kv put secret/staging/backoffice/api-creds @secrets/backoffice-staging-api-creds.json
	vault kv put secret/staging/backoffice/encryption-key @secrets/backoffice-staging-encryption-key.json

.PHONY: demo
demo: secrets
	./demo.sh
