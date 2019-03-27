To use this you need to replace a few variables first

1. "my-terraform-bucket" in terraform.tf, appspec.json.j2, deploy.sh
2. vpc_id in variables.tf
3. url in variables.tf
4. region in  deploy.sh if NOT using us-east-1


## Pip installs
pip install j2cli
pip install awscli

## If you don't have TF
brew install terraform 

or on linux:

wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
unzip terraform_0.11.13_linux_amd64.zip
rm -rf terraform_0.11.13_linux_amd64.zip
install terraform /usr/local/bin/

