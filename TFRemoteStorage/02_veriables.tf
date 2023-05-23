variable "remote_state_storage_s3" {
  type    = string
  default = "serverless-project-tf-storage"
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "prod"
}

variable "remote_state_dynamodb_table" {
  type    = string
  default = "serverless-project-tf-lock"
}

variable "remote_state_dynamodb_table_key" {
  type    = string
  default = "LockID"
}
