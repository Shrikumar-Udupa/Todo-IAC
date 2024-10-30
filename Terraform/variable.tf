variable "zg628t-todo-public-subnet-cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
 
variable "zg628t-todo-private-subnet-cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "zg628t-todo-azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "zg628t-todo-eks-cluster-allowed-ports" {
  description = "List of allowed ports"
  type        = list(number)
  default     = [80, 443, 6443, 2379, 2380, 10250, 10259, 10257, 53] # Kubernetes default ports
}

variable "zg628t-todo-eks-worker-allowed-ports" {
  description = "List of allowed ports"
  type        = list(number)
  default     = [10250, 10256, 53] # Kubernetes default ports
}

variable "zg628t-todo-eks-cluster-allowed-cidr" {
  description = "List of allowed CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change to restrict access as needed
}

variable "zg628t-todo-eks-worker-allowed-node-ports" {
  description = "Map for NodePort range"
  type        = map(number)
  default     = {
    from = 30000
    to   = 32767
  }
}

# List of ECR repository names
variable "ecr_repositories" {
  type    = list(string)
  default = ["todo-frontend", "todo-backend"]
}
