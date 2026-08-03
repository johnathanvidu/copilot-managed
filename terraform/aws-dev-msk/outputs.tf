output "connection_string" {
  description = "Preferred bootstrap brokers connection string for private TLS clients"
  value       = module.msk.bootstrap_brokers_tls
}

output "instance_type" {
  description = "Broker instance type"
  value       = var.broker_instance_type
}

output "cluster_arn" {
  description = "MSK cluster ARN"
  value       = module.msk.arn
}

output "transport_data" {
  description = "Network and transport details clients need in order to reach the private cluster"
  value = jsonencode({
    access_scope              = "private"
    client_broker_encryption  = "TLS"
    bootstrap_brokers_tls     = module.msk.bootstrap_brokers_tls
    port                      = 9094
    vpc_id                    = module.vpc.vpc_id
    private_subnet_ids        = module.vpc.private_subnets
    private_subnet_cidrs      = [var.private_subnet_1_cidr, var.private_subnet_2_cidr]
    broker_security_group_id  = aws_security_group.msk.id
    client_security_group_id  = aws_security_group.client.id
    client_requirements       = "Clients must run inside this VPC or through connected private networking and must be associated with the client security group or equivalent rules permitting outbound TLS to the broker security group on port 9094."
  })
}
