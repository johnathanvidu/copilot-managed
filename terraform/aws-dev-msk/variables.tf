variable "name_prefix" {
  description = "Prefix used to name the AWS resources"
  type        = string
  default     = "dev-msk"
}

variable "aws_region" {
  description = "AWS region for the VPC and MSK cluster"
  type        = string
  default     = "us-east-1"
}

variable "kafka_version" {
  description = "Apache Kafka version for the MSK cluster"
  type        = string
  default     = "3.6.0"
}

variable "broker_instance_type" {
  description = "Broker instance type for the dev cluster"
  type        = string
  default     = "kafka.t3.small"
}

variable "number_of_broker_nodes" {
  description = "Number of broker nodes to create for the dev cluster"
  type        = string
  default     = "2"
}

variable "broker_volume_size" {
  description = "EBS volume size in GiB per broker"
  type        = string
  default     = "10"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "private_subnet_1_cidr" {
  description = "CIDR for the first private subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR for the second private subnet"
  type        = string
  default     = "10.20.2.0/24"
}
