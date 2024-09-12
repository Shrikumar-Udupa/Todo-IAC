
data "tls_certificate" "zg628t-todo-eks-cluster-tls-certificate"{
 url = aws_eks_cluster.zg628t-todo-eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "zg628t-todo-eks-cluster-openid" {
  url = aws_eks_cluster.zg628t-todo-eks-cluster.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [data.tls_certificate.zg628t-todo-eks-cluster-tls-certificate.certificates[0].sha1_fingerprint]
}



resource "aws_iam_policy" "g628t-todo-eks-alb-policy" {
    policy = file("./AWSLoadBalancerController.json")
    name   = "AWSLoadBalancerController"

}


# LB-role.tf
data "aws_iam_policy_document" "g628t-todo-eks-ingress-iam-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"

    condition {
      test ="StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.zg628t-todo-eks-cluster-openid.url, "https://", "")}:sub"
      values = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.zg628t-todo-eks-cluster-openid.arn]
    }
  }
}

# LB-role.tf
resource "aws_iam_role" "g628t-todo-eks-ingress-role" {
  name = "g628t-todo-eks-ingress-role"
  assume_role_policy = data.aws_iam_policy_document.g628t-todo-eks-ingress-iam-policy.json
}

resource "aws_iam_role_policy_attachment" "g628t-todo-eks-ingress-iam-attach" {
  role = aws_iam_role.g628t-todo-eks-ingress-role.name
  policy_arn = aws_iam_policy.g628t-todo-eks-alb-policy.arn
}


resource "helm_release" "zg628t-todo-eks-load-balancer-controller"{
  depends_on = [aws_eks_cluster.zg628t-todo-eks-cluster]
  name = "zg628t-todo-eks-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart = "aws-load-balancer-controller"
  namespace = "kube-system"

  set {
    name = "replicaCount"
    value = 1
  }

  set{
    name = "clusterName"
    value = aws_eks_cluster.zg628t-todo-eks-cluster.name
  }

  set{
    name="vpcId"
    value = aws_vpc.zg628t-todo-vpc.id
  }

  set{
    name = "serviceAccount.name"
    value= "aws-load-balancer-controller"
  }

  set{
    name= "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.g628t-todo-eks-ingress-role.arn
  }
}
