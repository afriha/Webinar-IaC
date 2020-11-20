# Webinar AKS
A brief Terraform + Ansible + Gitlab-CI config that I made for a Webinar (Cloud ecosystem). The config deploys a small infra in a CI/CD workflow.  

## Usage
- Add your the required credentials in your gitlab-ci variables
- Run terraform init \
    -backend-config="address=https://gitlab.com/api/v4/projects/YOUR-PROJECT-ID/terraform/state/YOUR-PROJECT-NAME" \
    -backend-config="lock_address=https://gitlab.com/api/v4/projects/YOUR-PROJECT-ID/terraform/state/"YOUR-PROJECT-NAME"/lock" \
    -backend-config="unlock_address=https://gitlab.com/api/v4/projects/YOUR-PROJECT-ID/terraform/state/YOUR-PROJECT-NAME/lock" \
    -backend-config="username=YOUR-USERNAME" \
    -backend-config="password=YOUR-ACCESS-TOKEN" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5" in your local folder
- Makes changes, push to the master branch to run a plan and tag it if you want to run an apply (need manuel confirmation)

## Main Vars

variable "region" {}

variable "access_key" {}

variable "secret_key" {}

variable "ssh_key" {}
