output "glue_crawler_arns" {
    value = values(aws_glue_crawler.this)[*].arn 
}