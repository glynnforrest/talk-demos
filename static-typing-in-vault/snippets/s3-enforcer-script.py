data = vault_client.get(sys.argv[1])

for key in ['access_key_id', 'secret_access_key', 'bucket', 'region']:
    if key not in data:
        print('ERROR: Missing key ' + key)
        sys.exit(1)
