variable "name" {}
    
variable "region" {}

variable "env" {}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "url" {}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}
variable "project" {
  default = "Demo App"
}

variable "department" {
  default = "Medium"
}

variable "application" {
  type        = "string"
  description = "Application"
  default     = "Example app"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `name`, `project`, `application`, `department`, and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `policy` or `role`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map(`Cluster`,`XYZ`)"
}

