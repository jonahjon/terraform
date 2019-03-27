module "tags" {
  source      = "../tags" 
  project     = "${var.project}"
  application = "${var.application}"
  department  = "${var.department}"
  delimiter   = "${var.delimiter}"
  attributes  = ["private"]
  tags        = "${var.tags}"
}

data "aws_caller_identity" "current" {}

########### ALB Information #################

data "aws_lb_listener" "selected443" {
  load_balancer_arn = "${var.lb_arn}"
  port              = 443
}

######### ECS Stuff #########

resource "aws_codedeploy_app" "bluegreen" {
  compute_platform = "ECS"
  name             = "${var.env}-${var.name}"
}
resource "aws_codedeploy_deployment_group" "example" {
  app_name               = "${aws_codedeploy_app.bluegreen.name}"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "${var.name}"
  service_role_arn       = "${aws_iam_role.bluegreen.arn}"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = "${var.cluster_name}"
    service_name = "${var.service_name}"
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = ["${data.aws_lb_listener.selected443.arn}"]
      }

      target_group {
        name = "${var.tg_blue_name}"
      }

      target_group {
        name = "${var.tg_green_name}"
      }
    }
  }
}



resource "aws_iam_role" "bluegreen" {
  name = "${var.env}-${var.name}-bg"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "code_deploy_access" {
  name = "${var.env}-${var.name}"
  role = "${aws_iam_role.bluegreen.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "application-autoscaling:Describe*",
        "application-autoscaling:PutScalingPolicy",
        "application-autoscaling:DeleteScalingPolicy",
        "application-autoscaling:RegisterScalableTarget",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:PutMetricAlarm",
        "iam:AttachRolePolicy",
        "iam:CreateRole",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:GetRole",
        "iam:ListAttachedRolePolicies",
        "iam:ListRoles",
        "iam:ListGroups",
        "iam:ListUsers",
        "iam:PassRole",
        "iam:*",
        "codedeploy:*",
        "elasticloadbalancing:*",
        "logs:*",
        "ecr:*",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecs:*",
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "autoscaling:DescribeAutoScalingGroups",
        "ec2:*",
        "s3:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}