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

resource "aws_eks_access_entry" "g628t-todo-eks-developer-access-entry" {
  cluster_name      = aws_eks_cluster.zg628t-todo-eks-cluster.name
  principal_arn     = aws_iam_role.g628t-todo-eks-developer-role.arn #user-iam-arn
  kubernetes_groups = ["g628t-todo-eks-developer-group"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "g628t-todo-eks-developer-access-associate" {
  cluster_name  = aws_eks_cluster.zg628t-todo-eks-cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = aws_iam_role.g628t-todo-eks-developer-role.arn  #user-iam-arn

  access_scope {
    type       = "cluster"
  }
}

#############################

#Admin role


resource "aws_iam_user" "g628t-todo-eks-admin" {
  name = "g628t-todo-eks-admin"

  tags = {
    creator = "g628t-todo-eks-admin"
  }
}

resource "aws_iam_group" "g628t-todo-eks-admin-group" {
  name = "g628t-todo-eks-admin-group"
}

resource "aws_iam_group_membership" "g628t-todo-eks-admin-group-membership" {
  name = aws_iam_user.g628t-todo-eks-admin.name
  users = [aws_iam_user.g628t-todo-eks-admin.name]
  group = aws_iam_group.g628t-todo-eks-admin-group.name
}

resource "aws_iam_role" "g628t-todo-eks-admin-role" {
  name = "g628t-todo-eks-admin-role"

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

resource "aws_iam_policy" "g628t-todo-eks-iam-admin-policy" {
  name        = "g628t-todo-eks-iam-admin-policy"
  description = "Policy to allow EKS cluster admin access"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:*",
          "ec2:DescribeInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:CreateSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateTags",
          "iam:PassRole",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRole",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer"
        ],
        Resource = "*"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "g628t-todo-eks-iam-admin-attach"{
  role       = aws_iam_role.g628t-todo-eks-admin-role.name
  policy_arn = aws_iam_policy.g628t-todo-eks-iam-admin-policy.arn
}


resource "aws_iam_group_policy" "g628t-todo-eks-admin-assume-role" {
  group  = aws_iam_group.g628t-todo-eks-admin-group.name
  name   = "AllowAssumeRolePolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Resource = aws_iam_role.g628t-todo-eks-admin-role.arn
    }]
  })
}

resource "aws_eks_access_entry" "g628t-todo-eks-admin-access-entry" {
  cluster_name      = aws_eks_cluster.zg628t-todo-eks-cluster.name
  principal_arn     = aws_iam_role.g628t-todo-eks-admin-role.arn #user-iam-arn
  kubernetes_groups = ["g628t-todo-eks-admin-group"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "g628t-todo-eks-admin-access-associate" {
  cluster_name  = aws_eks_cluster.zg628t-todo-eks-cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.g628t-todo-eks-admin-role.arn  #user-iam-arn

  access_scope {
    type       = "cluster"
  }
}

#aws configure
#aws sts assume-role --role-arn "arn:aws:iam::825765396418:role/g628t-todo-eks-admin-role" --role-session-name AWSCLI-Session
#export AWS_ACCESS_KEY_ID=RoleAccessKeyID
#export AWS_SECRET_ACCESS_KEY=RoleSecretKey
#export AWS_SESSION_TOKEN=RoleSessionToken
#aws eks update-kubeconfig --region us-east-1 --name zg628t-todo-eks-cluster