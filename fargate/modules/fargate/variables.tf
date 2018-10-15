variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "vpc" {
  type = "map"
  default = 
  {
    dev  = "vpc-1234567" 
    qa   = "vpc-2345678"
    prod = "vpc-3345679"
  }
}

variable "acm_cert" {
  type    = "map"
  default =
  {
    my_app_1      = "arn:aws:acm:us-east-1:XXXXXXXXXXXXXXX:certificate/XXXXXXXXXXXXXXX"
    my_app_2      = "arn:aws:acm:us-east-1:XXXXXXXXXXXXXXX:certificate/XXXXXXXXXXXXXXX"
  }
}

variable "url" {
    type    = "map"
    default =
    {
        my_app_1            = "myapp1.com"
        my_app_2            = "myapp2.com"
    }
} 



variable "NAME" {}
    
variable "REGION" {}

variable "ENV" {}

variable "HEALTHCHECK" {
  type = "map"
  default = 
  {
    my_app_1    = "/hello"
    my_app_2    = "/world"
  }
}

variable "zoneid" {
  type = "map"
  default = 
    dev       = "XXXXXXXXXXXXX"
    qa        = "XXXXXXXXXXXXX"
    prod      = "XXXXXXXXXXXXX"
}

#value = ${lookup(var.account_environments, var.ENV)}
variable "account_environments" {
  type = "map"
  default =
  {
    dev      = "XXXXXXXXXXXXX",
    qa       = "XXXXXXXXXXXXX",
    prod     = "XXXXXXXXXXXXX"
  }
}
