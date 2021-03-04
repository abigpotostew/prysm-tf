usage

Step 1 set your environment variables:
```
cp .env.example .env
<modify .env variables here>
source .env

```

Step 2 create a gcp project and bucket for storing terraform lock state

    cd <root>/terraform/backend-gcs
    terraform init
    terraform apply

Step 3 deploy the application project, the VPC, the postgres db with private ip in the VPC, and the app engine project and versions

    cd <root>/terraform/pg-priv-stew
    terraform init
    terraform apply

