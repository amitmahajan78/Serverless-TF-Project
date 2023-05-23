resource "aws_s3_bucket" "s3_tf_state" {
  bucket = var.remote_state_storage_s3
  lifecycle {
    prevent_destroy = false
  }
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "s3_tf_state_versioning" {
  bucket = aws_s3_bucket.s3_tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_tf_state_access" {
  bucket = aws_s3_bucket.s3_tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# resource "null_resource" "destroy_s3_tf_bucket" {
#   provisioner "local-exec" {
#     command = "aws s3 rm s3://${aws_s3_bucket.s3_tf_state.id} --recursive && aws s3api delete-bucket --bucket ${aws_s3_bucket.s3_tf_state.id}"
#   }
#   depends_on = [aws_s3_bucket_public_access_block.s3_tf_state_access]
# }
