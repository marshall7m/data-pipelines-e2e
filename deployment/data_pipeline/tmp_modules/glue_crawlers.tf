resource "aws_glue_crawler" "crawlers" {
    for_each = {for crawler in var.glue_crawlers:  crawler.name => crawler}
    name = each.key
    role = aws_iam_role.glue.arn
    database_name = "each.value.data_catalog"

    s3_target {
        path = each.value.s3_target.path 
    }

    schema_change_policy {
        update_behavior = each.value.schema_change_policy.update_behavior
        delete_behavior = each.value.schema_change_policy.delete_behavior
    }

    tags = each.value.tags
}