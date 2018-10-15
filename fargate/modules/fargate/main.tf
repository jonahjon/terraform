data "aws_subnet_ids" "subnets" {
  vpc_id = "${var.vpc["${var.ENV}"]}"
}

resource "aws_s3_bucket" "terraform_fargate_state" {
  bucket = "terraform-state-bucket"
  versioning {
    enabled = true
  }
}
############# LB STUFF ################
resource "aws_alb" "main" { 
  name            = "${var.NAME}"
  internal        = true
  subnets         = ["${data.aws_subnet_ids.subnets.ids[0]}", "${data.aws_subnet_ids.subnets.ids[1]}"]
  security_groups = ["${aws_security_group.lb.id}"]
}

resource "aws_alb_target_group" "app" {
  name        = "${var.NAME}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${var.vpc["${var.ENV}"]}"
  target_type = "ip"
  health_check {
      path    = "${var.HEALTHCHECK["${var.NAME}"]}"
      matcher = "200"
  }
}
resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type            = "redirect"
    redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
    }
  }
}
resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.acm_cert["${var.NAME}"]}"
  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type             = "forward"
  }
}

############### SG STUFF ################
resource "aws_security_group" "lb" {
  name        = "${var.NAME}_sg_alb"
  description = "controls access to the ALB"
  vpc_id      = "${var.vpc["${var.ENV}"]}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name        = "${var.NAME}-alb"
  }
}
resource "aws_security_group" "app" {
  name        = "${var.NAME}_sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${var.vpc["${var.ENV}"]}"

  ingress {
    protocol        = "tcp"
    from_port       = 53
    to_port         = 53
    cidr_blocks     = ["10.0.0.0/8"]
    security_groups = ["${aws_security_group.lb.id}"]
  }
  ingress {
    protocol        = "udp"
    from_port       = 53
    to_port         = 53
    cidr_blocks     = ["10.0.0.0/8"]
    security_groups = ["${aws_security_group.lb.id}"]
  }
  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    cidr_blocks     = ["10.0.0.0/8"]
    security_groups = ["${aws_security_group.lb.id}"]
  }
  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    cidr_blocks     = ["10.0.0.0/8"]
    security_groups = ["${aws_security_group.lb.id}"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name        = "${var.NAME}"
  }
}

################# ECS STUFF ################
resource "aws_ecs_cluster" "main" {
  name = "${var.NAME}"
}


 resource "aws_ecr_repository" "main" {
   name = "${var.NAME}"
 }

data "template_file" "task_def" {
  template = "${file("${path.module}/task_def.json")}"
  vars {
    container_name     = "${var.NAME}"
    account_id         = "${var.account_environments["${var.ENV}"]}"
    environment        = "${var.ENV}"
    region             = "${var.REGION}"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.NAME}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  container_definitions    = "${data.template_file.task_def.rendered}"
  execution_role_arn       = "${aws_iam_role.role.arn}"
  task_role_arn            = "${aws_iam_role.role.arn}"
}

data "aws_ecs_task_definition" "app" {
  task_definition = "${aws_ecs_task_definition.app.family}"
}

resource "aws_ecs_service" "main" {
  name            = "${var.NAME}"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.app.family}:${max("${aws_ecs_task_definition.app.revision}", "${data.aws_ecs_task_definition.app.revision}")}"
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = ["${aws_security_group.app.id}"]
    subnets         = ["${data.aws_subnet_ids.subnets.ids[0]}", "${data.aws_subnet_ids.subnets.ids[1]}"]
  }
  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name   = "${var.NAME}"
    container_port   = 80
  }
  depends_on = [
    "aws_ecs_task_definition.app",
    "aws_alb_listener.https"
    ]
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "ecs/${var.ENV}-${var.NAME}"
  tags {
    Environment = "${var.ENV}"
    Application = "${var.NAME}"
  }
}

resource "aws_route53_record" "dns_name" {
  zone_id                   = "${var.zoneid["${var.ENV}"]}"
  name                      = "${var.url["${var.NAME}"]}"
  type                      = "CNAME"
  ttl                       = 60
  records                   = ["${aws_alb.main.dns_name}"]
}

############### IAM STUFF ##############
resource "aws_iam_role" "role" {
  name = "${var.NAME}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid":"110"
    }
  ]
}EOF
}

resource "aws_iam_role_policy_attachment" "role_attachment" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "fargate_state" {
  name = "fargate_state_policy"
  role = "${aws_iam_role.role.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.terraform_fargate_state.arn}/*",
        "${aws_s3_bucket.terraform_fargate_state.arn}"
      ]
    }
  ]
}
EOF
}
