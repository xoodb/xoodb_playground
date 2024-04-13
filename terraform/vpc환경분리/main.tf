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

/* 개발용 */
module "dev_custom_vpc" {
  source = "./custom_vpc"
  env = "dev"
}

# module.dev_custom_vpc.vpc_id = vpc의 id를 가져올수있다 output 지정으로 인해

/* 운영용 */
module "production_custom_vpc" {
  source = "./custom_vpc"
  env = "prd"
}