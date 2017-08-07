# Automated Setup of PostgreSQL and DB Restore from AWS S3

## Assumptions
- Terraform binary (>=0.9.0) is downloaded and accessible via $PATH
- A PostgreSQL is created with a system user postgres and accessible via TCP
- All PostgreSQL host info + AWS S3 info is ready at hand

## Executiong steps
- Copy over terraform.tfvars.example to terraform.tfvars
- Fill in all the values
- Run "terraform plan" to see what will be done; take note if there is any errors
- If it looks OK, run "terraform apply" and it should be completed without error