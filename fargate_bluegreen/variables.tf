variable "region" {
    default = "us-east-1"
}

variable "region2" {
    default = "us-east-2"
}
variable "env" {
    default = "dev"
}
variable "name" {
    default = "test-app"
}

variable "vpc_id" {
    type    = "map"
    default =
    {   
        dev        = "vpc-12345678"
    }
}

variable "url" {
    default = "wwww.example.com"
}


