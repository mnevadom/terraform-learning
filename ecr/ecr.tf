terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
} 

provider "aws" {
  region = var.regionmnm
  access_key = ""
  secret_key = ""
}

resource "aws_ecr_repository" "devl-auth" {
  name                 = "dgp-reg/authserver"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "devl-companies" {
  name                 = "dgp-reg/companies"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "devl-content" {
  name                 = "dgp-reg/contentmoderator"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "devl-cron" {
  name                 = "dgp-reg/cronservice"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "devl-email" {
  name                 = "dgp-reg/email-service"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "devl-game" {
  name                 = "dgp-reg/game-service"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "devl-notis" {
  name                 = "dgp-reg/notificationservice"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "post" {
  name                 = "dgp-reg/postservice"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}