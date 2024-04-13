terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  cloud {
    hostname = "app.terraform.io"
    organization = "terraform-test-xoodb"
    workspaces {
      name = "terraform-prd"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

module "main_vpc" {
  source = "./custom_vpc"
  env    = terraform.workspace
}

resource "aws_s3_bucket" "tf_backend" {
  count  = terraform.workspace == "default" ? 1 : 0 #한쪽에서만 관리할때 사용
  bucket = "xoodb-tf-backend"

  tags = {
    Name = "xoodb_backend"
  }
}

resource "aws_s3_bucket_ownership_controls" "tf_ownership" {
  count  = terraform.workspace == "default" ? 1 : 0
  bucket = aws_s3_bucket.tf_backend[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tf_backend_acl" { #s3 private 설정으로 외부 접근 차단
  count      = terraform.workspace == "default" ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.tf_ownership[0]]

  bucket = aws_s3_bucket.tf_backend[0].id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tf_backend_ver" {
  count  = terraform.workspace == "default" ? 1 : 0 
  bucket = aws_s3_bucket.tf_backend[0].id
  versioning_configuration {
    status = "Enabled"
  }
} 