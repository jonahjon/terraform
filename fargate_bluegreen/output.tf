output "service_arn" {
  value = ["${module.example.service_arn}"]
}

output "service_name" {
  value = ["${module.example.service_name}"]
}

output "cluster_name" {
  value = ["${module.example.cluster_name}"]
}

output "task_family" {
  value = ["${module.example.task_family}"]
}


output "task_revision" {
  value = ["${module.example.task_revision}"]
}

output "task_arn" {
  value = ["${module.example.task_arn}"]
}

output "code_deploy_app" {
  value = ["${module.bluegreen.code_deploy_app}"]
}

output "deployment_group" {
  value = ["${module.bluegreen.deployment_group}"]
}

