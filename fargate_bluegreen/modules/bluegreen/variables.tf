variable "name" {}
    
variable "env" {}

variable "lb_arn" {
  
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


variable "cluster_name" {}

variable "service_name" {}

variable "tg_blue_name" {}

variable "tg_green_name" {}