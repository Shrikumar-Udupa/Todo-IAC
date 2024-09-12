data "aws_caller_identity" "g628t-todo-aws-account" {}

resource "aws_iam_user" "g628t-todo-eks-developer" {
  name = "g628t-todo-eks-developer"

  tags = {
    creator = "g628t-todo-eks-developer"
  }
}

resource "aws_iam_group" "g628t-todo-eks-developer-group" {
  name = "g628t-todo-eks-developer-group"
}

resource "aws_iam_group_membership" "g628t-todo-eks-developer-group-membership" {
  name = aws_iam_user.g628t-todo-eks-developer.name
  users = [aws_iam_user.g628t-todo-eks-developer.name]
  group = aws_iam_group.g628t-todo-eks-developer-group.name
}

resource "aws_iam_role" "g628t-todo-eks-developer-role" {
  name = "g628t-todo-eks-developer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.g628t-todo-aws-account.account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "g628t-todo-eks-iam-developer-policy" {
  name        = "g628t-todo-eks-iam-developer-policy"
  description = "Policy to allow EKS cluster READ access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:ListUpdates"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "g628t-todo-eks-iam-developer-attach"{
  role       = aws_iam_role.g628t-todo-eks-developer-role.name
  policy_arn = aws_iam_policy.g628t-todo-eks-iam-developer-policy.arn
}


resource "aws_iam_group_policy" "g628t-todo-eks-developer-assume-role" {
  group  = aws_iam_group.g628t-todo-eks-developer-group.name
  name   = "AllowAssumeRolePolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Resource = aws_iam_role.g628t-todo-eks-developer-role.arn
    }]
  })
}