data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = [var.private_subnet_1_cidr, var.private_subnet_2_cidr]
  cluster_name    = "${var.name_prefix}-cluster"
  common_tags = {
    Blueprint = "aws-dev-msk-cluster"
    ManagedBy = "Torque"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets

  enable_nat_gateway = false
  enable_vpn_gateway = false
  create_igw         = false

  tags = local.common_tags
}

resource "aws_security_group" "client" {
  name        = "${var.name_prefix}-client-sg"
  description = "Client security group allowed to reach the private MSK brokers"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-client-sg"
  })
}

resource "aws_security_group" "msk" {
  name        = "${var.name_prefix}-msk-sg"
  description = "Security group for private MSK brokers"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "TLS Kafka from the dedicated client security group"
    from_port       = 9094
    to_port         = 9094
    protocol        = "tcp"
    security_groups = [aws_security_group.client.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-msk-sg"
  })
}

module "msk" {
  source  = "terraform-aws-modules/msk-kafka-cluster/aws"
  version = "~> 2.0"

  name                      = local.cluster_name
  kafka_version             = var.kafka_version
  number_of_broker_nodes    = tonumber(var.number_of_broker_nodes)
  broker_node_instance_type = var.broker_instance_type

  broker_node_client_subnets  = module.vpc.private_subnets
  broker_node_security_groups = [aws_security_group.msk.id]
  broker_node_storage_info = {
    ebs_storage_info = {
      volume_size = tonumber(var.broker_volume_size)
    }
  }

  encryption_in_transit_client_broker = "TLS"
  encryption_in_transit_in_cluster    = true

  tags = merge(local.common_tags, {
    Name = local.cluster_name
  })
}
