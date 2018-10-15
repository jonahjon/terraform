For this to work in an automated fashion I use this in a CICD pipeline


```
export TF_VAR_NAME=$CI_PROJECT_NAME
export TF_VAR_REGION=${REGION}
export TF_VAR_ENV=${ENV}
export TF_VAR_ACCESS=$ACCESS_KEY
export TF_VAR_SECRET=$SECRET_KEY
export TF_VAR_TOKEN=$SESSION_TOKEN

terraform get
terraform init -input=false
terraform plan-input=false  -out=tfplan
terraform apply -input=false tfplan
export CLUSTER="terraform output cluster_arn"
export APP_URL="terraform output url"
sls deploy
```

