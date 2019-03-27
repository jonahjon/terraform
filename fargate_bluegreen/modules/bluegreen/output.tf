output "code_deploy_app" {
  value = "${element(split(":", aws_codedeploy_app.bluegreen.id),1)}"
}

output "deployment_group" {
  value = "${var.name}"
}

