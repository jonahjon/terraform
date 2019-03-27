This is a module that can be used to tag any and every resource in a complient fashion

How to use?

Add these variables to your variables.tf in the sub-module (db/splunk/etc)

############## SUB_MODULE ######################

variables.tf

variable "name" {
  type        = "string"
  description = "Name (e.g. `example`)"
}

variable "project " {
  type        = "string"
  description = "Project  (e.g. `example` or `example`)"
}

variable "application" {
  type        = "string"
  description = "Application (e.g. `example`)"
}

variable "department" {
  type        = "string"
  description = "department (e.g. `PAG`)"
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



Add the module the main.tf  in the submodule

main.tf

module "tags" {
  source      = "git::ssh://git@git.acadian-asset.com/here/here-terraform.git//modules/tags
  name        = "${var.name}"
  project     = "${var.project}"
  application = "${var.application}
  department  = "${var.department}
  delimiter   = "${var.delimiter}"
  attributes  = ["private"]
  tags        = "${var.tags}"
}


and then call this tags module in every resource tag section:

resource "aws_internet_gateway" "default" {
  vpc_id = "${var.vpc_id}"
  tags   = "${module.tags.tags}"
}



########### PARENT MODULE ##############

In the parent module you can define tags for your sub-modules as such, to gaurentee governence on each sub-module, and easy configuration changes replicated down to every compenent of the application via the parent defintion.

module "vpc" {
  source             = "modules/vpc"

  name               = "app-name"
  project            = "example"
  application        = "example"
  department         = "medium"
}