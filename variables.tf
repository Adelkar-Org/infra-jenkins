variable "region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "environment" {
  default = "dev"
}

variable "ami_id" {
  description = "The AMI ID for the Jenkins instance"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "elastic_ip_allocation_id" {
  description = "The allocation ID for the Elastic IP"
}

variable "domain" {
  description = "The domain name for the Jenkins instance"
}
