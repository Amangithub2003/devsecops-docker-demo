variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  type    = string
  default = "demo-app"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type running Docker + docker-compose"
  type        = string
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "Existing EC2 key pair for SSH access (Jenkins deploys over SSH)"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH in (lock this down to your Jenkins/office IP)"
  type        = string
  default     = "0.0.0.0/0"
}
