data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name                 = "${var.project_name}-vpc"
  cidr                 = "172.11.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.11.1.0/24", "172.11.2.0/24", "172.11.3.0/24"]
  public_subnets       = ["172.11.4.0/24", "172.11.5.0/24", "172.11.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}


#Security group
resource "aws_security_group" "vpc_sg" {
  vpc_id = module.vpc.vpc_id

  # Full inbound access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops_SG"
  }
}