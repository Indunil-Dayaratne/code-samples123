# Introduction 
This is the Sharepoint Online DMS codebase. All legacy code from TFS (for which there is no build or deployment pipeline) is under legacy.

# Getting Started with Infrastructure

Clone https://dev.azure.com/britgroupservices/PSCloudModules/_git/TerraformModules and ensure that it is located in the same directory as brit-dms-source.

To execute terraform plan locally, ensure that TF 0.12.24 is available locally and execute the following:

1. az login
1. az account set --subscription b88ff083-a2b3-420a-bb38-b4c4ee5a28ec
1. terraform init --backend-config=backend-config/partial_config-nonprod.tf
1. terraform workspace select dev
1. terraform plan -var-file="./terraform-vars/dev.terraform.tfvars"