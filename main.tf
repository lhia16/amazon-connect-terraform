data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_canonical_user_id" "current" {}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.43.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}