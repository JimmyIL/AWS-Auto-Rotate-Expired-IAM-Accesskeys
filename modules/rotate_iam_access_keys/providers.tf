#this may not be needed, but make sure the terraform version is ">= 1.0.5" , and aws provider is ">=4.4.0"
terraform {
  backend "s3" {}
  required_version = ">= 1.0.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.4.0"
    }
  }
}
