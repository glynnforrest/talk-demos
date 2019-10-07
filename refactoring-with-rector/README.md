# Rector examples

## 1. Upgrade and fix a simple Twig extension

```bash
cd 1-twig-extension

# Upgrade to twig 2.4.0
../vendor/bin/rector process src --set twig 240

# Use fully qualified class imports
../vendor/bin/rector process src -c imports.yaml
```

Note that the master branch of rector supports not importing root classnames (e.g. `\DateTimeInterface`).

## 2. Fix messy code

```bash
cd 2-messy-code

../vendor/bin/rector process .
```

Note the use of `%vendor%` to import the *code-quality* set.

## 4. Custom rector

```bash
cd 4-custom-rector

../vendor/bin/rector process src -c custom.yaml
```
