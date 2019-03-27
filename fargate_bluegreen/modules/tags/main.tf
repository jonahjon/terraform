locals {
  enabled = "${var.enabled == "true" ? true : false }"

  # Only maps that contain all the same attribute types can be merged, so the values have been set to list
  context_struct = {
    project     = []
    application = []
    department  = []
    attributes  = []
    tags_keys   = []
    tags_values = []
    delimiter   = []
    label_order = []
  }

  # Merge the map of empty values, with the variable context, so that context_local always contains all map keys
  context_local = "${merge(local.context_struct, var.context)}"

  # Provided variables take precedence over the variables from the provided context IF they're not the default
  # if thing == default and if local_context[thing] != ""
  #   local_context[thing]
  # else
  #   thing

  projects                     = "${concat(local.context_local["project"], list(""))}"
  project_context_or_default   = "${length(local.projects[0]) > 0 ? local.projects[0] : var.project}"
  project_or_context           = "${var.project != "" ? var.project : local.project_context_or_default}"
  project                      = "${lower(replace(local.project_or_context, "/[^a-zA-Z0-9]/", ""))}"
  applications                   = "${concat(local.context_local["application"], list(""))}"
  application_context_or_default = "${length(local.applications[0]) > 0 ? local.applications[0] : var.application}"
  application_or_context         = "${var.application != "" ? var.application : local.application_context_or_default}"
  application                    = "${lower(replace(local.application_or_context, "/[^a-zA-Z0-9]/", ""))}"
  departments                         = "${concat(local.context_local["department"], list(""))}"
  department_context_or_default       = "${length(local.departments[0]) > 0 ? local.departments[0] : var.department}"
  department_or_context               = "${var.department != "" ? var.department : local.department_context_or_default}"
  department                          = "${lower(replace(local.department_or_context, "/[^a-zA-Z0-9]/", ""))}"

  delimiters                     = "${concat(local.context_local["delimiter"], list(""))}"
  delimiter_context_or_default   = "${length(local.delimiters[0]) > 0 ? local.delimiters[0] : var.delimiter}"
  delimiter                      = "${var.delimiter != "-" ? var.delimiter : local.delimiter_context_or_default}"
  # Merge attributes
  attributes = ["${distinct(compact(concat(var.attributes, local.context_local["attributes"])))}"]
  # Generate tags (don't include tags with empty values)
  generated_tags = "${zipmap(
    compact(list(local.project != "" ? "Project" : "", local.application != "" ? "Application" : "", local.department != "" ? "Department" : "")),
    compact(list(local.project, local.application, local.department))
    )}"
  tags                     = "${merge(zipmap(local.context_local["tags_keys"], local.context_local["tags_values"]), local.generated_tags, var.tags)}"
  tags_as_list_of_maps     = ["${data.null_data_source.tags_as_list_of_maps.*.outputs}"]
  label_order_default_list = "${list("project", "application", "department", "attributes")}"
  label_order_context_list = "${distinct(compact(local.context_local["label_order"]))}"
  label_order_final_list   = ["${distinct(compact(coalescelist(var.label_order, local.label_order_context_list, local.label_order_default_list)))}"]
  label_order_length       = "${(length(local.label_order_final_list))}"
  # Context of this label to pass to other label modules

  output_context = {
    project     = ["${local.project}"]
    application = ["${local.application}"]
    department  = ["${local.department}"]
    attributes  = ["${local.attributes}"]
    tags_keys   = ["${keys(local.tags)}"]
    tags_values = ["${values(local.tags)}"]
    delimiter   = ["${local.delimiter}"]
    label_order = ["${local.label_order_final_list}"]
  }
  id_context = {
    project     = "${local.project}"
    application = "${local.application}"
    department  = "${local.department}"
    attributes  = "${lower(join(local.delimiter, local.attributes))}"
  }
  id = "${lower(join(local.delimiter, compact(list(
    "${local.label_order_length > 0 ? local.id_context[element(local.label_order_final_list, 0)] : ""}",
    "${local.label_order_length > 1 ? local.id_context[element(local.label_order_final_list, 1)] : ""}",
    "${local.label_order_length > 2 ? local.id_context[element(local.label_order_final_list, 2)] : ""}",
    "${local.label_order_length > 3 ? local.id_context[element(local.label_order_final_list, 3)] : ""}",
    "${local.label_order_length > 4 ? local.id_context[element(local.label_order_final_list, 4)] : ""}"))))}"
}

data "null_data_source" "tags_as_list_of_maps" {
  count = "${local.enabled ? length(keys(local.tags)) : 0}"

  inputs = "${merge(map(
    "key", "${element(keys(local.tags), count.index)}",
    "value", "${element(values(local.tags), count.index)}"
  ),
  var.additional_tag_map)}"
}