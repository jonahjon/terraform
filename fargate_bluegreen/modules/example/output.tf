output "task_revision" {
    value = "${aws_ecs_task_definition.app.revision}"
}

output "task_family" {
    value = "${aws_ecs_task_definition.app.family}"
}

output "task_arn" {
    value = "${aws_ecs_task_definition.app.arn}"
}

output "lb_arn" {
  value = "${aws_alb.lb.arn}"
}


output "service_arn" {
  value = "${aws_ecs_service.main.id}"
}

output "service_name" {
  value = "${aws_ecs_service.main.name}"
}

output "log_arn" {
  value = "${aws_cloudwatch_log_group.ecs.arn}"
}

output "log_name" {
  value = "${aws_cloudwatch_log_group.ecs.name}"
}

output "cluster_name" {
  value = "${var.name}-${var.env}"
}

output "tg_blue_name" {
  value = "${aws_alb_target_group.blue.name}"
}

output "tg_green_name" {
  value = "${aws_alb_target_group.green.name}"
}

output "tg_blue_arn" {
  value = "${aws_alb_target_group.blue.arn}"
}

output "tg_green_arn" {
  value = "${aws_alb_target_group.green.arn}"
}