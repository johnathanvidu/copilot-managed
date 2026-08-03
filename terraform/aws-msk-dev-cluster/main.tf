locals {
  availability_zones          = jsondecode(var.availability_zones)
  private_subnets             = jsondecode(var.private_subnets)
  broker_storage_info         = jsondecode(var.broker_storage_info)
  allowed_client_ingress      = jsondecode(var.allowed_client_ingress_rules)
  tags                        = jsondecode(var.tags)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = var.name_prefix
  cidr = var.vpc_cidr
  azs  = local.availability_zones

  private_subnets = local.private_subnets
  public_subnets  = []

  enable_nat_gateway      = false
  single_nat_gateway      = false
  one_nat_gateway_per_az  = false
  create_igw              = false
  map_public_ip_on_launch = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

module "kafka_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  name        = "${var.name_prefix}-brokers"
  description = "Private access for MSK brokers"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = local.allowed_client_ingress
  egress_rules = {
    all = {
      description = "Allow all outbound"
      cidr_ipv4   = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
    }
  }

  tags = local.tags
}

module "msk" {
  source  = "terraform-aws-modules/msk-kafka-cluster/aws"
  version = "3.3.0"

  name                        = var.name_prefix
  kafka_version               = var.kafka_version
  number_of_broker_nodes      = 2
  broker_node_instance_type   = var.broker_instance_type
  broker_node_client_subnets  = module.vpc.private_subnets
  broker_node_security_groups = [module.kafka_sg.id]
  broker_node_storage_info    = local.broker_storage_info

  create_schema_registry      = false
  create_configuration        = false
  create_cloudwatch_log_group = false
  cloudwatch_logs_enabled     = false
  s3_logs_enabled             = false
  firehose_logs_enabled       = false
  enhanced_monitoring         = "DEFAULT"
  enable_storage_autoscaling  = false

  client_authentication = {
    sasl = {
      iam = true
    }
  }

  encryption_in_transit_client_broker = "TLS"
  encryption_in_transit_in_cluster    = true

  tags = local.tags
}