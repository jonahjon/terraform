terraform {
    backend "s3" {
        bucket = "my-terraform-bucket"
        key    = "myapp/dev/terraform.tfstate"
        region = "us-east-1"
    }
}
