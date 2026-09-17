module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.app_name}-vpc"
  cidr = var.vpc_cidr

  azs            = ["${var.aws_region}a"]
  public_subnets = ["10.0.101.0/24"]

  enable_dns_hostnames = true
}
