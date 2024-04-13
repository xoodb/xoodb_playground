AWS EKS terraform 구축

폴더 구조 
```shell
├── README.md 
├── backend.tf 
├── data.tf 
├── main.tf 
├── modules 
│   └── eks-cluster 
│       ├── data.tf 
│       ├── main.tf 
│       ├── output.tf 
│       ├── provider.tf 
│       └── variables.tf 
│   └── custom-vpc
│       ├── main.tf 
│       ├── output.tf 
│       └── variables.tf 
├── output.tf 
└── provider.tf 

```

VPC구조
- public Subnet 2개 (AZ 이중화)
- private Subnet 2개 (AZ 이중화)
- IGW
- NAT