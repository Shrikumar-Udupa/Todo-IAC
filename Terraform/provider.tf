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




