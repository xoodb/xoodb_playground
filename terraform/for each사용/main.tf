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

variable "names" {
  type = list(string)
  default = [ "kim", "lee" ]
}

module "personal_custom_vpc" {
  for_each = toset(var.names) #map 이여야 사용가능 따라서 변환 (타입 캐스팅)
  #for_each = toset([for name in var.names : "${name}_human"]) 이름 뒤에 유형 추가
  source = "./custom_vpc"
  env = "personal_${each.key}"
} 

# count를 사용할 경우 예시
/* module "personal_custom_vpc" {
  count = 2
  source = "./custom_vpc"
  env = "personal_${count.index}"
} */