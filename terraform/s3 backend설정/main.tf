terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # s3가 생성되어 있어야함
  backend "s3" {
    bucket = "jty-tf-backend"
    key    = "terraform.tfstate"
    region = "ap-northeast-2"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

variable "envs" {
  type    = list(string)
  default = ["dev", "prd", ""]
}

module "vpc_list" {
  for_each = toset([for env in var.envs : env if env != ""])
  source   = "./custom_vpc"
  env      = each.key
}

resource "aws_s3_bucket" "tf_backend" {
  bucket = "xoodb-tf-backend"

  tags = {
    Name = "xoodb_backend"
  }
}

resource "aws_s3_bucket_ownership_controls" "tf_ownership" {
  bucket = aws_s3_bucket.tf_backend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tf_backend_acl" { #s3 private 설정으로 외부 접근 차단
  depends_on = [aws_s3_bucket_ownership_controls.tf_ownership]

  bucket = aws_s3_bucket.tf_backend.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tf_backend_ver" {
  bucket = aws_s3_bucket.tf_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}