provider "aws" {}

data "aws_subnet_ids" "subnets" {
  vpc_id = "${var.vpc_id["${var.env}"]}"
}

data "aws_caller_identity" "current" {}

module "example" {
 source         = "modules/example" 
 name           = "${var.name}"
 region         = "${var.region}"
 env            = "${var.env}"
 vpc_id         = "${var.vpc_id["${var.env}"]}"
 url            = "${var.url}"
 subnet_ids     = [
    "${data.aws_subnet_ids.subnets.ids[0]}",
    "${data.aws_subnet_ids.subnets.ids[1]}"
  ]
}

module "bluegreen" {
 source         = "modules/bluegreen" 
 name           = "${var.name}"
 env            = "${var.env}"
 cluster_name   = "${module.example.cluster_name}"
 service_name   = "${module.example.service_name}"
 tg_blue_name   = "${module.example.tg_blue_name}"
 tg_green_name  = "${module.example.tg_green_name}"
 lb_arn         = "${module.example.alb_arn}"
}
