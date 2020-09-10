resource "aws_s3_bucket" "private_bucket" {
  bucket = "private-sparkify"
  acl    = "private"

  tags = {
    name        = "private-sparkify"
    environment = "${var.env}"
  }
}

resource "aws_s3_bucket_public_access_block" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  block_public_acls   = true
  block_public_policy = true
}
