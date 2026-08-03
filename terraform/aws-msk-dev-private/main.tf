provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_id" "suffix" {
  byte_length = 2
}

locals {
  cluster_name = "${var.name_prefix}-${random_id.suffix.hex}"

  allowed_client_cidrs = length(trimspace(var.allowed_client_cidrs_csv)) > 0 ? [
    for cidr in split(",", var.allowed_client_cidrs_csv) : trimspace(cidr)
  ] : [var.vpc_cidr]

  common_tags = {
    Blueprint   = "aws-msk-dev-private"
    Environment = "dev"
    ManagedBy   = "Torque"
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-vpc"
  })
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_a_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-private-a"
    Tier = "private"
  })
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_b_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-private-b"
    Tier = "private"
  })
}

resource "aws_security_group" "msk" {
  name_prefix = "${local.cluster_name}-msk-"
  description = "Private access to the MSK brokers"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Kafka TLS from approved client networks"
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = local.allowed_client_cidrs
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-msk-sg"
  })
}

resource "aws_msk_cluster" "this" {
  cluster_name           = local.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = tonumber(var.broker_nodes)

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    client_subnets  = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups = [aws_security_group.msk.id]

    storage_info {
      ebs_storage_info {
        volume_size = tonumber(var.broker_volume_gib)
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  tags = merge(local.common_tags, {
    Name = local.cluster_name
  })
}
