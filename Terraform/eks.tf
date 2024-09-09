#IAM role has access to EKS
resource "aws_iam_role" "zg628t-todo-eks-role" {
  name = "zg628t-todo-eks"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "zg628t-todo-AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.zg628t-todo-eks-role.name
}


resource "aws_eks_cluster" "zg628t-todo-eks-cluster" {
  name     = "g628t-todo-eks-cluster"
  role_arn = aws_iam_role.zg628t-todo-eks-role.arn
  vpc_config {
    subnet_ids = [for subnet in aws_subnet.zg628t-todo-private-subnet : subnet.id]
    security_group_ids      = [aws_security_group.zg628t-todo-eks-cluster-sg.id, aws_security_group.zg628t-todo-eks-worker-sg.id]
  }

  depends_on = [aws_iam_role_policy_attachment.zg628t-todo-AmazonEKSClusterPolicy]
}


resource "aws_iam_role" "zg628t-todo-nodes-group-role" {
  name = "zg628t-todo-nodes-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "g628t-todo-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.zg628t-todo-nodes-group-role.name
}

resource "aws_iam_role_policy_attachment" "g628t-todo-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.zg628t-todo-nodes-group-role.name
}

resource "aws_iam_role_policy_attachment" "g628t-todo-nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.zg628t-todo-nodes-group-role.name
}


resource "aws_eks_node_group" "g628t-todo-eks-worker-node-group" {
  cluster_name  = aws_eks_cluster.zg628t-todo-eks-cluster.name
  node_group_name = "g628t-todo-eks-worker-node-group"
  node_role_arn  = aws_iam_role.zg628t-todo-nodes-group-role.arn
  count    = length(aws_subnet.zg628t-todo-private-subnet)
  subnet_ids   = [for subnet in aws_subnet.zg628t-todo-private-subnet : subnet.id]
  instance_types = ["t3.xlarge"]
 
  scaling_config {
   desired_size = 1
   max_size   = 1
   min_size   = 1
  }
 
  depends_on = [
   aws_iam_role_policy_attachment.g628t-todo-nodes-AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.g628t-todo-nodes-AmazonEKS_CNI_Policy,
   aws_iam_role_policy_attachment.g628t-todo-nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
 }

 