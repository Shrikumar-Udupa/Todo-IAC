
# Create ECR repositories using a loop
resource "aws_ecr_repository" "repositories" {
  for_each            = toset(var.ecr_repositories)  # Converts the list to a set for unique values
  name                = each.value
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true  # Enable image scanning on push
  }
}