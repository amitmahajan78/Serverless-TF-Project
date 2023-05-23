resource "random_pet" "fx-processing-bucket_name" {
  prefix = "fx-processing-function"
  length = 2
}

resource "aws_s3_bucket" "fx-processing-bucket" {
  bucket        = random_pet.fx-processing-bucket_name.id
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "fx-processing-bucket_acl" {
  bucket = aws_s3_bucket.fx-processing-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
