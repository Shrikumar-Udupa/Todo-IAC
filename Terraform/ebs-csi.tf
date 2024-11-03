data "aws_iam_policy_document" "g628t-todo-eks-ebs-csidriver-iam-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"

    condition {
      test ="StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.zg628t-todo-eks-cluster-openid.url, "https://", "")}:sub"
      values = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.zg628t-todo-eks-cluster-openid.arn]
    }
  }
}

resource "aws_iam_role" "g628t-todo-eks-ebs-csidriver-role" {
  name = "g628t-todo-eks-ebs-csidriver-role"
  assume_role_policy = data.aws_iam_policy_document.g628t-todo-eks-ebs-csidriver-iam-policy.json
}

resource "aws_iam_role_policy_attachment" "g628t-todo-eks-ebs-csidriver-iam-attach" {
  role = aws_iam_role.g628t-todo-eks-ebs-csidriver-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "g628t-todo-eks-ebs-csidriver" {
  cluster_name                = aws_eks_cluster.zg628t-todo-eks-cluster
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.19.0-eksbuild.2" #e.g., previous version v1.9.3-eksbuild.3 and the new version is v1.10.1-eksbuild.1
  service_account_role_arn    = aws_iam_role.g628t-todo-eks-ebs-csidriver-role
}