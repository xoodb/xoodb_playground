module "vpc" {
  # vpc 설정
  source = "./modules/custom-vpc"
  env    = "dev"
}

module "eks" {
  # eks 모듈에서 사용할 변수 정의
  source          = "./modules/eks-cluster"
  cluster_name    = "jty-test-cluster"
  cluster_version = "1.24"
  vpc_id          = module.vpc.vpc_id

  private_subnets = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  public_subnets  = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
}