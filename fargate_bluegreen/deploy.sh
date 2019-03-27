#!/bin/bash

terraform get
terraform init -input=false

# We got to run these two modules seperate
terraform plan -out=tfplan -target=module.example
terraform apply -input=false tfplan

terraform plan -out=tfplan -target=module.bluegreen
terraform apply -input=false tfplan


export task_arn=$(terraform output task_arn)
export code_deploy_app=$(terraform output code_deploy_app)
export deployment_group=$(terraform output deployment_group)


j2 deployment.json.j2 > deployment.json
j2 appspec.json.j2 > appspec.json
aws s3 cp deployment.json s3://my-terraform-bucket/deployment.json
deployid=$(aws deploy create-deployment --cli-input-json file://appspec.json | jq -r '.deploymentId')
echo "https://console.aws.amazon.com/codesuite/codedeploy/deployments/$deployid?region=us-east-1"