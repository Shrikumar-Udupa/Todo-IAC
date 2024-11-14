resource "helm_release" "g628t-todo-eks-argocd" {
 depends_on = [aws_eks_node_group.g628t-todo-eks-worker-node-group]
 name       = "argocd"
 repository = "https://argoproj.github.io/argo-helm"
 chart      = "argo-cd"
 version    = "5.21.1"
 namespace = "argocd"
 create_namespace = true
 timeout = 6000 
 set {
   name  = "server.service.type"
   value = "LoadBalancer"
 }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }
  set {
    name  = "server.ingress.hosts[0]"
    value = ""  # Replace with your own domain or leave it empty for basic LB access
  }


}



