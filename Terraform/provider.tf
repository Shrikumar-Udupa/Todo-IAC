terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.65.0"
    }
  }
  backend "s3" {
  bucket         	   = "g628t-todo-s3-tfstate"
  key              	   = "state/terraform.tfstate"
  region         	   = "us-east-1"
  encrypt        	   = true
  dynamodb_table = "g628t-todo-tfstate-dynamodb"
  }
}

provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::825765396418:role/g628t-todo-terraform-role" 
    session_name = "g628t-todo-terraform"
  }
  region = "us-east-1"
}


provider "kubernetes" {
  host                   = aws_eks_cluster.g628t-todo-eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.g628t-todo-eks-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.g628t-todo-eks-cluster.token
}

data "aws_eks_cluster_auth" "zg628t-todo-eks-cluster-auth" {
  depends_on = [aws_eks_cluster.zg628t-todo-eks-cluster]
  name       = aws_eks_cluster.zg628t-todo-eks-cluster.name
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.zg628t-todo-eks-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.zg628t-todo-eks-cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.zg628t-todo-eks-cluster-auth.token
  }
}