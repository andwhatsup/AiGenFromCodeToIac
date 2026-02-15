# Variable for AWS Region
variable "region" {
  type        = string
  description = "This is the Provider's Region"
}

# Variable for vpc cidr
variable "vpc_cidr" {
  type        = string
  description = "Variable for your vpc cidr block"

}

# Create a variable for your vpc dns support
variable "dns_support" {
  type        = string
  description = "This is a variable for your dns support"
}

# Variable for DNS hostnames
variable "dns_hostnames" {
  type        = string
  description = "This is a variable for my vpc hostnames"
}

# Variable for vpc tags
variable "vpc_tags" {
  type        = map(string)
  description = "This is the variable for my vpc tags"
  default = {
    Name        = "main_vpc"
    Environment = "Production"
    Team        = "DevOps"
  }
}

# Variable for IGW
variable "igw_tags" {
  type = map(string)
  default = {
    Name        = "vpc_igw"
    Environment = "Production"
    Team        = "DevOps"
  }
}

# variable for public subnet one cidr
variable "pub_one_cidr" {
  type        = string
  description = "cidr for first public subnet"
}

# variable for public subnet two cidr

variable "pub_two_cidr" {
  type        = string
  description = "cidr for second public subnet"
}

# Varible for private subnet one cidr
variable "priv_one_cidr" {
  type        = string
  description = "cidr for first private subnet"
}

# Variable for private subnet twp cidr
variable "priv_two_cidr" {
  type        = string
  description = "cidr for second private subnet"
}
# Variables for Public Subnets cidrs
# variable "pub_cidr" {
#  type    = list(string)
#  default = ["10.0.1.0/24", "10.0.2.0/24"]
#}

# Variable for public ip on launch for Public subnets
variable "public_ip_launch" {
  type    = string
  default = true
}

# Variable for azs
#variable "subnet_azs" {
#  type    = list(string)
#  default = ["eu-west-2a", "eu-west-2b"]
#}

# variable for Private subnets cidrs
# variable "priv_cidr" {
#  type    = list(string)
#  default = ["10.0.3.0/24", "10.0.4.0/24"]
#}

# variable for 1st availability zone
variable "az_one" {
  type        = string
  description = "az for my first public or private subnet"
}

# Create a variable for 2nd availability zone
variable "az_two" {
  type        = string
  description = "az for my second public or private subnet"
}

# Variable for your VPC_ID
variable "vpc_id" {
  type = string
}

# Variable for Subnet_ID
#variable "subnet_ids" {
#   type = list(string)
#}



# Variable for EKS name
#variable "name" {
#   type = string
#   description = "my eks cluster name"
#}

# Variable for EKS Cluster Version
variable "eks_version" {
  type        = string
  description = "EKS Version"
}

# Variable for worker nodes name
# variable "node_group_name" {
#  description = "Name of the EKS node group."
#  default     = "my-node-group"
#}

# Variable for worker nodes desired capacity

variable "desired_size" {
  description = "The desired number of worker nodes."
  type        = number
  default     = 2
}
# Variable for worker nodes min size
variable "min_size" {
  description = "The minimum number of worker nodes."
  type        = number
  default     = 1
}

# variable for Worker nodes max size
variable "max_size" {
  description = "The maximum number of worker nodes."
  type        = number
  default     = 8
}

# variable for worker nodes ami type
variable "ami_type" {
  type        = string
  description = "AMI type for your worker nodes"
}

# variable for instance types
variable "instance_types" {
  type    = list(string)
  default = ["t3.small", "t3.medium", "t3.large"]
}

# Variable for worker nodes capacity type
variable "capacity_type" {
  type        = string
  description = "a variable for your worker nodes capacity type"
}

# Variable disk size for Worker Nodes
variable "disk_size" {
  type        = string
  description = "Disk size for your Worker Nodes"
  default     = "50"
}

# Variable for EKS Cluster role name
#variable "eks_cluster_role_name" {
#  type        = string
#  description = "Name of the IAM role for the EKS cluster."
#  default     = "eks-cluster-role"
#}

# Variable for Worker nodes Role Name
#variable "eks_node_role_name" {
#  type      = string
#  description = "Name of the IAM role for EKS worker nodes."
#  default     = "eks-node-role"
#}

# Variable for count for our Public and Private Subnets
# variable "sub_count" {
#   type = string
#   description = "This is count variable for your subnets"
#}

# variable for max unavailable nodes
variable "max_unavailable" {
  type        = string
  description = "max unavailable nodes for your worker nodes"
  default     = 1
}