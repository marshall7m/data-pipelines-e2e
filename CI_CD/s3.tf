resource "aws_s3_bucket" "private_bucket" {
  bucket = var.private_bucket_name
  acl    = "private"

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket" "tf_state_bucket" {
  count = var.tf_state_bucket_name != var.private_bucket_name? 1 : 0
  bucket = var.tf_state_bucket_name
  acl    = "private"

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "tf_state_bucket" {
  count = var.tf_state_bucket_name != var.private_bucket_name? 1 : 0
  bucket = aws_s3_bucket.tf_state_bucket[0].id

  block_public_acls   = true
  block_public_policy = true
}