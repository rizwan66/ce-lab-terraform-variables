# m4-02-terraform-variables

Terraform lab demonstrating variable definitions, validation rules, and multi-environment deployments using `.tfvars` files and workspaces.

## What This Creates

An AWS S3 bucket per environment with:
- Public access fully blocked
- Optional versioning (enabled in prod, disabled in dev)
- Environment-specific tagging

## Project Structure

```
m4-02-terraform-variables/
├── main.tf                 # S3 bucket, versioning, and public access block resources
├── variables.tf            # Input variable definitions with types and validation
├── outputs.tf              # Output values (bucket ID, ARN, region, versioning status)
├── dev.tfvars              # Variable values for the development environment
├── prod.tfvars             # Variable values for the production environment
└── compare-environments.sh # Script to compare versioning and tags across environments
```

## Variables

| Name | Type | Default | Description |
|---|---|---|---|
| `aws_region` | `string` | `"us-east-1"` | AWS region for all resources |
| `environment` | `string` | — | Environment name; must be `dev`, `staging`, or `prod` |
| `bucket_prefix` | `string` | — | Prefix for the S3 bucket name; lowercase letters, numbers, hyphens only |
| `enable_versioning` | `bool` | `false` | Enable S3 bucket versioning |
| `tags` | `map(string)` | `{}` | Additional tags to merge onto all resources |

## Validation Rules

**`environment`** — enforces allowed values:
```hcl
condition     = contains(["dev", "staging", "prod"], var.environment)
error_message = "Environment must be dev, staging, or prod."
```

**`bucket_prefix`** — enforces S3-safe naming:
```hcl
condition     = can(regex("^[a-z0-9-]+$", var.bucket_prefix))
error_message = "Bucket prefix must contain only lowercase letters, numbers, and hyphens."
```

## Environment Configurations

### dev.tfvars
```hcl
environment       = "dev"
bucket_prefix     = "myapp-677746"
enable_versioning = false        # versioning off to save cost in dev
aws_region        = "us-east-1"

tags = {
  Owner   = "DevTeam"
  Project = "CloudBootcamp"
  Cost    = "Development"
}
```

### prod.tfvars
```hcl
environment       = "prod"
bucket_prefix     = "myapp-677746"
enable_versioning = true         # versioning on for data protection in prod
aws_region        = "us-east-1"

tags = {
  Owner   = "PlatformTeam"
  Project = "CloudBootcamp"
  Cost    = "Production"
  Backup  = "Daily"
}
```

## Usage

### First-time setup

```bash
terraform init
```

### Deploy dev environment

```bash
terraform workspace select default
terraform apply -var-file=dev.tfvars
```

### Deploy prod environment

```bash
terraform workspace new prod      # only needed once
terraform workspace select prod
terraform apply -var-file=prod.tfvars
```

### Compare environments

```bash
bash compare-environments.sh
```

### Tear down an environment

```bash
# Switch to the workspace you want to destroy
terraform workspace select default
terraform destroy -var-file=dev.tfvars
```

## Deployed Outputs

### Dev (workspace: default)

| Output | Value |
|---|---|
| `bucket_id` | `myapp-677746-dev-bucket` |
| `bucket_arn` | `arn:aws:s3:::myapp-677746-dev-bucket` |
| `bucket_region` | `us-east-1` |
| `versioning_enabled` | `false` |

### Prod (workspace: prod)

| Output | Value |
|---|---|
| `bucket_id` | `myapp-677746-prod-bucket` |
| `bucket_arn` | `arn:aws:s3:::myapp-677746-prod-bucket` |
| `bucket_region` | `us-east-1` |
| `versioning_enabled` | `true` |

## Screenshots

Screenshots are located in the `screenshots/` folder:

| File | Shows |
|---|---|
| `dev-apply.png` | `terraform apply` output for the dev workspace |
| `prod-apply.png` | `terraform apply` output for the prod workspace |
| `compare-output.png` | Output of `compare-environments.sh` showing both buckets |
| `workspace-list.png` | `terraform workspace list` showing both workspaces |

## Requirements

- Terraform >= 1.6.0
- AWS provider ~> 5.0
- AWS credentials configured (`aws configure` or environment variables)
