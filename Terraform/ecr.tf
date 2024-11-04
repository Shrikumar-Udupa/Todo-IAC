# Attempt to fetch existing ECR repositories
data "aws_ecr_repository" "g628t-todo-ecr-repositories" {
  for_each = toset(var.ecr-repositories)
  name     = each.key
}

# Create ECR repositories only if they don’t already exist
resource "aws_ecr_repository" "repositories" {
  for_each = { for repo in var.ecr-repositories : repo => repo if try(data.aws_ecr_repository.g628t-todo-ecr-repositories[repo].repository_name, null) == null }
  name     = each.key
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}