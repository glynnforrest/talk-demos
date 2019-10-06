# Rector examples

## Upgrade and fix a simple Twig extension

```bash
cd 1-twig-extension

# Upgrade to twig 2.4.0
../vendor/bin/rector process src --set twig 240

# Use fully qualified class imports
../vendor/bin/rector process src -c imports.yaml
```

Note that the master branch of rector supports not importing root classnames (e.g. `\DateTimeInterface`).
