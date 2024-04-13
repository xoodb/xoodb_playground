terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

module "default_custom_vpc" {
  source = "./custom_vpc"
}

module "production_custom_vpc" {
  source = "./custom_vpc"
}