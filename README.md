# terraform

Terraform 101:

```

brew install terraform

mkdir terraform

cd terraform

vi main.tf

```




write template:

Example Template:

```
provider "aws" {
	region = "us-east-1"
	access_key = "YOUR_KEY_HERE"
	secret_key = "YOUR_KEY_HERE"
}

resource "aws_instance" "LOGICAL_NAME_EXAMPLE" {
	ami = 			"ami-97785bed"
	instance_type = "t2.micro"
}
```


Make the template happen, and key the resources it produces
```
Initilize:							terraform init

Apply all .tf files in directory:	terraform apply

View your State File outupts:		cat terraform.tfstate
```

To add resources to your template

```
provider "aws" {
	region = "us-east-1"
	access_key = "YOUR_KEY_HERE"
	secret_key = "YOUR_KEY_HERE"
}
resource "aws_s3_bucket" "bucket" {

	bucket = "BUCKET_NAME"
}

resource "aws_instance" "LOGICAL_NAME_EXAMPLE" {
	ami = 			"ami-97785bed"
	instance_type = "t2.micro"
	depends_on = ["aws_s3_bucket.bucket"]
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.example.id}"
}
```
