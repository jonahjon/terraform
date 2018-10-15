terraform {
    backend "s3" {
        bucket = "terraform-state-bucket"
        key    = "${REPO}/${ENV}/terraform.tfstate"
        region = "${REGION}"
    }
}
