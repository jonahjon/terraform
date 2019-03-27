module "tags" {
  source      = "../tags" 
  name        = "${var.env}-${var.name}"
  project     = "${var.project}"
  application = "${var.application}"
  department  = "${var.department}"
  delimiter   = "${var.delimiter}"
  attributes  = ["private"]
  tags        = "${var.tags}"
}

###################
#
# DNS
#
###################

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "zone" {
  # Will need to figure out how to do a split for this part of url variable
  name          = "example.com."
  private_zone  = false
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.url}"
  validation_method = "DNS"
  tags              = "${module.tags.tags}"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.zone.id}"
  name    = "${var.url}"
  type    = "A"

  alias {
    name                   = "${aws_alb.lb.dns_name}"
    zone_id                = "${aws_alb.lb.zone_id}"
    evaluate_target_health = true
  }
  depends_on = [
  "aws_acm_certificate_validation.cert"
  ]
}

###################
#
# Security Groups
#
###################


# api
resource "aws_security_group" "sg" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.env}-${var.name}-ecs"
  description = "Allows ingress from load balancers"
  tags            = "${module.tags.tags}"
}

resource "aws_security_group_rule" "sg-https" { 
  type              = "ingress" 
  from_port         = 443
  to_port           = 443
  protocol          = "tcp" 
  security_group_id = "${aws_security_group.sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg-http" { 
  type              = "ingress" 
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

################################
#
#Load balancers, TG, Listeners
#
###################################

resource "aws_alb" "lb" {
  name            = "${var.env}-${var.name}"
  internal        = true
  subnets         = ["${var.subnet_ids}"]
  security_groups = ["${aws_security_group.sg.id}"]
  tags            = "${module.tags.tags}"
}

resource "aws_alb_target_group" "blue" {
  name                 = "${var.env}-${var.name}-blue"
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  health_check { 
	  path               = "/" 
    matcher            = "200"
  } 
  tags                 = "${module.tags.tags}"
}

resource "aws_alb_target_group" "green" {
  name                 = "${var.env}-${var.name}-green"
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  health_check { 
	  path               = "/" 
    matcher            = "200"
  } 
  tags                 = "${module.tags.tags}"
}



resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.lb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_acm_certificate.cert.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.green.id}"
    type             = "forward"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

###################
#
# ECS
#
###################
resource "aws_ecs_cluster" "app" {
  name     = "${var.env}-${var.name}"
  tags     = "${module.tags.tags}"
}

data "template_file" "task_def" {
  template = "${file("${path.module}/task.json")}"
  vars {
    environment                       = "${var.env}"
    accountid                         = "${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.env}-${var.name}"
  network_mode             = "awsvpc"
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  container_definitions    = "${data.template_file.task_def.rendered}"
  execution_role_arn       = "${var.iam_role}"
  task_role_arn            = "${var.iam_role}"
  requires_compatibilities = ["FARGATE"]
  tags                     = "${module.tags.tags}"
}

data "aws_ecs_task_definition" "app" {
  depends_on = ["aws_ecs_task_definition.app"]
  task_definition = "${aws_ecs_task_definition.app.family}"
}

resource "aws_ecs_service" "app" {
  name               = "${var.env}-${var.name}"
  task_definition    = "${aws_ecs_task_definition.app.family}:${max("${aws_ecs_task_definition.app.revision}", "${data.aws_ecs_task_definition.app.revision}")}"
  desired_count      = "${var.aws_ecs_service_desired_count}"
  launch_type        = "FARGATE"
  cluster            = "${aws_ecs_cluster.app.id}"
  load_balancer {
    target_group_arn = "${aws_alb_target_group.green.arn}"
    container_name   = "${var.name}"
    container_port   = 80
  }
  network_configuration {
    assign_public_ip  = false
    security_groups   = ["${aws_security_group.sg.id}"]
    subnets           = ["${var.subnet_ids}"]
  }
  depends_on = [
    "aws_ecs_task_definition.app"
  ]
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"
  tags                    = "${module.tags.tags}"
}

###################
#
# Logs
#
###################

resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.env}-${var.name}"
  retention_in_days   = 365
  tags                = "${module.tags.tags}"
}