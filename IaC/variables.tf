
###################
# AWS Config
###################
variable "aws_region" {
  default     = "us-east-1"
  description = "aws region where our resources going to create choose"
}

variable "aws_access_key" {
  type = string
  description = "aws_access_key"
}

variable "aws_secret_key" {
  type = string
  description = "aws_secret_key"
}

###################
# Project Config
###################

variable "project_name" {
  description = "Project Name"
  default     = "DemoTSZ201"
}

variable "ecr_name_prefix" {
  description = "Project Name"
  default     = "demotsz"
}


variable "node_desired_size" {
  description = " Desired number of worker nodes."
  default     = 1
}

variable "node_max_size" {
  description = " Maximum number of worker nodes."
  default     = 1
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  default     = 1
}

variable "node_instance_type" {
  description = "The instance type of worker node."
  default     = "t3.xlarge"
}
