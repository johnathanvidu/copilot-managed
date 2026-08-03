output "cluster_name" {
  description = "Generated MSK cluster name"
  value       = aws_msk_cluster.this.cluster_name
}

output "cluster_arn" {
  description = "Amazon Resource Name of the MSK cluster"
  value       = aws_msk_cluster.this.arn
}

output "connection_string" {
  description = "TLS bootstrap brokers connection string for Kafka clients"
  value       = aws_msk_cluster.this.bootstrap_brokers_tls
}

output "bootstrap_brokers_tls" {
  description = "TLS bootstrap brokers endpoints"
  value       = aws_msk_cluster.this.bootstrap_brokers_tls
}

output "broker_instance_type" {
  description = "Broker instance type"
  value       = var.broker_instance_type
}

output "listener_port" {
  description = "Kafka client listener port"
  value       = 9094
}

output "vpc_id" {
  description = "Dedicated VPC ID"
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs hosting the brokers"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "private_subnet_cidrs" {
  description = "CIDRs of the private broker subnets"
  value       = [aws_subnet.private_a.cidr_block, aws_subnet.private_b.cidr_block]
}

output "brokers_security_group_id" {
  description = "Security group attached to the MSK brokers"
  value       = aws_security_group.msk.id
}

output "allowed_client_cidrs" {
  description = "CIDR ranges allowed to reach the brokers over TLS"
  value       = local.allowed_client_cidrs
}

output "transport_summary" {
  description = "Transport and reachability details needed by Kafka clients"
  value = jsonencode({
    bootstrap_brokers_tls    = aws_msk_cluster.this.bootstrap_brokers_tls
    listener_port            = 9094
    transport                = "TLS"
    authentication           = "Network-based access inside private VPC reachability"
    vpc_id                   = aws_vpc.this.id
    private_subnet_ids       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    private_subnet_cidrs     = [aws_subnet.private_a.cidr_block, aws_subnet.private_b.cidr_block]
    brokers_security_group   = aws_security_group.msk.id
    allowed_client_cidrs     = local.allowed_client_cidrs
    reachability_requirement = "Clients must have private network reachability into the VPC, such as a workload in the VPC, peering, VPN, or Direct Connect."
  })
}
