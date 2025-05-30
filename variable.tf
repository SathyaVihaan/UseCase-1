
variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_az1" {
  description = "The CIDR block for subnet in AZ1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_az2" {
  description = "The CIDR block for subnet in AZ2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_cidr_az3" {
  description = "The CIDR block for subnet in AZ3"
  type        = string
  default     = "10.0.3.0/24"
}

variable "instance_type" {
  description = "The instance type for EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Replace with a valid AMI ID
}
