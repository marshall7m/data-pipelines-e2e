resource "aws_athena_database" "databases" {
  for_each = {for database in var.athena_databases: database.name => database}
  name   = each.key
  bucket = each.value.bucket
}

resource "aws_athena_workgroup" "workgroups" {
  for_each = {for workgroup in var.athena_workgroups: "workgroup.name" => workgroup}
  name = each.key

  configuration {
    enforce_workgroup_configuration = lookup(
      each.value.configuration, "enforce_workgroup_configuration", 
      true
    )

    result_configuration {
      output_location = each.value.configuration.result_configuration.output_location
    }
  }

  tags = each.value.tags
}

resource "aws_athena_named_query" "queries" {
  for_each = {for query in var.athena_queries: query.name => query}
  name = each.key
  query = each.value.query
  database = each.value.database
  workgroup = each.value.workgroup
}