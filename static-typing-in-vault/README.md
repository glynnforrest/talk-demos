# 'Static Typing' in Vault demo

A demo of the `vault-helper.py` script I use to validate the schema of secrets in a Vault KV secrets engine.

## Run the demo

Get the dependencies:

```bash
brew install docker vault bat jq
```

Start Vault in a docker container:

```bash
make run
```

Copy the Vault root token that is shown in the container's logs.

In another terminal:

```bash
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=<copied_token>
make demo
```
