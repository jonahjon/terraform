provider "aws" {
  access_key = "${var.ACCESS}"
  secret_key = "${var.SECRET}"
  token      = "${var.TOKEN}"
  region     = "${var.REGION}"
}

module "fargate" {
  source    = "modules/fargate"

  NAME      = "${var.NAME}"
  REGION    = "${var.REGION}"
  ENV       = "${var.ENV}"
  app_count = "${var.COUNT}"
}
