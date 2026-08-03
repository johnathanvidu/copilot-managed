variable "region" {
  description = "AWS region for the MSK cluster and networking resources"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix used to generate the MSK cluster name"
  type        = string
  default     = "dev-msk"
}

variable "kafka_version" {
  description = "Amazon MSK Kafka version"
  type        = string
  default     = "3.6.0"
}

variable "broker_instance_type" {
  description = "Broker instance type for the dev cluster"
  type        = string
  default     = "kafka.t3.small"
}

variable "broker_nodes" {
  description = "Number of broker nodes. This blueprint is intentionally sized for a minimal 2-broker dev cluster."
  type        = string
  default     = "2"

  validation {
    condition     = var.broker_nodes == "2"
    error_message = "This dev blueprint currently supports exactly 2 broker nodes."
  }
}

variable "broker_volume_gib" {
  description = "EBS volume size in GiB per broker"
  type        = string
  default     = "100"

  validation {
    condition     = can(tonumber(var.broker_volume_gib)) && tonumber(var.broker_volume_gib) >= 1
    error_message = "broker_volume_gib must be a numeric value greater than or equal to 1."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for the first private subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for the second private subnet"
  type        = string
  default     = "10.20.2.0/24"
}

variable "allowed_client_cidrs_csv" {
  description = "Optional comma-separated CIDRs allowed to reach Kafka over TLS. Leave empty to allow only the VPC CIDR."
  type        = string
  default     = ""
}
