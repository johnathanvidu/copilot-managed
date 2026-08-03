output "connection_string" {
  value = module.msk.bootstrap_brokers_sasl_iam
}

output "instance_type" {
  value = var.broker_instance_type
}

output "cluster_arn" {
  value = module.msk.arn
}

output "transport_data" {
  value = join(" | ", [
    "bootstrap=${module.msk.bootstrap_brokers_sasl_iam}",
    "vpc_id=${module.vpc.vpc_id}",
    "private_subnets=${jsonencode(module.vpc.private_subnets)}",
    "security_group_id=${module.kafka_sg.id}",
    "port=9098",
    "auth=SASL_IAM",
    "encryption=TLS",
    "public_access=disabled"
  ])
}