terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  cloud { # terraform cloud 사용
    hostname     = "app.terraform.io"
    organization = "terraform-test-taeyoon"
    workspaces {
      name = "terraform-prd"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

module "default_vpc" {
  source = "terraform-aws-modules/vpc/aws" # 외부 모듈 사용

  name = "default_vpc_${terraform.workspace}"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets  = ["10.0.100.0/24", "10.0.101.0/24"]

  # 싱글 인터넷 게이트웨이 사용
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  manage_default_security_group = true # 보안그룹 추가

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}