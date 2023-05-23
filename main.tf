
module "fx-quote" {
  source = "./FxQuote"
}

module "fx-payment" {
  source = "./FxPayment"
}

module "fx-platform" {
  depends_on = [module.fx-payment]
  source     = "./FxProcessingPlatform"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.21.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "serverless-project-tf-storage"
    key    = "terraform.tfstate"
    region = "eu-west-1"

    # For State Locking
    dynamodb_table = "serverless-project-tf-lock"
  }

  required_version = "~> 1.0"
}
