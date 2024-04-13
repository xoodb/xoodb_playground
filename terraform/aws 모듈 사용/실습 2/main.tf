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

  azs            = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets = ["10.0.100.0/24", "10.0.101.0/24"]

  manage_default_security_group = true # 보안그룹 추가

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_instance" "web_instances" {
  count         = 2
  ami           = "ami-0bc4327f3aabf5b71"
  instance_type = "t3.micro"

  subnet_id = module.default_vpc.public_subnets[count.index] # 각 az에 하나씩 생성

  tags = {
    Name = "web_${count.index}"
  }
}

module "web-elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 2.0"

  name = "web-elb-${terraform.workspace}"

  subnets         = module.default_vpc.public_subnets
  security_groups = [module.default_vpc.default_security_group_id]
  internal        = false

  listener = [
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    }
  ]

  health_check = { #필수
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
/* 
  access_logs = {
    bucket = "my-access-logs-bucket"
  } */

  // ELB attachments
  number_of_instances = 2
  instances           = aws_instance.web_instances[*].id # * 은 카운트 변경시 수가 변경됨

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
