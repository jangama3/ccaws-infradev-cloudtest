terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.35.0"
    }
  }
  required_version = "~>1.6.0"
  backend "s3" {
    bucket         = "terraform-bucket-582316382845"
    key            = "ccaws-raildev-timsdev/terraform.tfstate"
    dynamodb_table = "terraform-table-582316382845"
    region         = "us-east-1"
  }
}

provider "aws" {
  # Configuration options
  region = var.region
}
