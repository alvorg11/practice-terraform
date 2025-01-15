terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.82.2"
    }
  }
  backend "s3" {
    bucket = "timing-remot-state"
    key    = "timing"
    region = "ap-south-1"
    dynamodb_table = "timing-lock"
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}