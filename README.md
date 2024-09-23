# AutoMate
These are Automation Scripts

these are the `OpenTofu` Scripts. Related Documentation:

Installation: https://opentofu.org/docs/intro/

Usages: https://opentofu.org/docs/intro/core-workflow/

The Safeset way of using Open Tofu :

1. Initialize plugins and OpenTofu:

```
tofu init
```
2. Re-check:

```
tofu plan
```

3. Confirm Changes:

```
tofu apply
```
4. To supply a custom `.tfvars`

```
tofu plan -var-file="encrypted.tfvars"
```
```
tofu apply -var-file="encrypted.tfvars"
```
```
tofu destroy -var-file="sample.tfvars"
```