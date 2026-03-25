# ECR Repositories
resource "aws_ecr_repository" "frontend" {
  provider             = aws.primary
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "backend" {
  provider             = aws.primary
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Cross Region Replication
resource "aws_ecr_replication_configuration" "crr" {
  provider = aws.primary

  replication_configuration {
    rule {
      destination {
        region      = var.secondary_region
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}

data "aws_caller_identity" "current" {
  provider = aws.primary
}
