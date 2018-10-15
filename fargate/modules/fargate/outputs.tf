output "cluster_arn" {
  value = ${aws_ecs_cluster.main.id}
 }
output "url" {
  value = "${var.url["${var.NAME}"]}"
 }
