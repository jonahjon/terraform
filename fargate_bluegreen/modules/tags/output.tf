output "id" {
  value       = "${local.enabled ? local.id : ""}"
  description = "Disambiguated ID"
}

output "project" {
  value       = "${local.enabled ? local.project : ""}"
  description = "Normalized project"
}

output "application" {
  value       = "${local.enabled ? local.application : ""}"
  description = "Normalized application"
}

output "department" {
  value       = "${local.enabled ? local.department : ""}"
  description = "Normalized department"
}

output "attributes" {
  value       = "${local.attributes}"
  description = "List of attributes"
}

output "delimiter" {
  value       = "${local.enabled ? local.delimiter : ""}"
  description = "Delimiter between `project`, `department`, `application`, `name` and `attributes`"
}

output "tags" {
  value       = "${local.tags}"
  description = "Normalized Tag map"
}

output "tags_as_list_of_maps" {
  value       = ["${local.tags_as_list_of_maps}"]
  description = "Additional tags as a list of maps, which can be used in several AWS resources"
}

output "context" {
  value       = "${local.output_context}"
  description = "Context of this module to pass to other label modules"
}

output "label_order" {
  value       = "${local.label_order_final_list}"
  description = "The naming order of the id output and Name tag"
}