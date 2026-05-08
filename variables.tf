variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "The environment to deploy resources in (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition    = contains(["dev", "staging", "prod"], var.env)
    error_message = "The environment must be one of 'dev', 'staging', or 'prod'."
  }
}

variable "home_ip" {
    description = "Your home IP address for SSH access to the Kafka cluster."
    type        = string
}

variable "instance_type" {
    description = "The EC2 instance type for the Kafka cluster."
    type        = string
    default     = "t3.micro"
}

