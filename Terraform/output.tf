'''output "g628t_todo_eks_argocd_server_url" {
  description = "The external URL for accessing Argo CD"
  value = (
    length(helm_release.g628t-todo-eks-argocd.status[0].load_balancer.ingress) > 0 ?
    helm_release.g628t-todo-eks-argocd.status[0].load_balancer.ingress[0].hostname :
    "LoadBalancer not available yet"
  )
}

'''