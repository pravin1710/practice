terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"

    }
  }

  backend "s3" {
    bucket = "sh-bucket"
    key    = "states-terraform"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = var.aws_region
}
