variable "name_prefix" {
  type        = string
  description = "Prefix used for AWS resource names"
}

variable "aws_region" {
  type        = string
  description = "AWS region for the VPC and MSK cluster"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "availability_zones" {
  type        = string
  description = "JSON list of availability zones"
}

variable "private_subnets" {
  type        = string
  description = "JSON list of private subnet CIDRs"
}

variable "broker_instance_type" {
  type        = string
  description = "MSK broker instance type"
}

variable "kafka_version" {
  type        = string
  description = "Kafka version"
}

variable "broker_storage_info" {
  type        = string
  description = "JSON object for broker storage configuration"
}

variable "allowed_client_ingress_rules" {
  type        = string
  description = "JSON map of ingress rules for Kafka clients"
}

variable "tags" {
  type        = string
  description = "JSON map of tags"
}