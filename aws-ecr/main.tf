provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "default" {
  name = var.repository_name
}