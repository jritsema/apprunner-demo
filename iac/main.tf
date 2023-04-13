terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      "app"         = var.app
      "environment" = "dev"
    }
  }
}

variable "app" {
  type        = string
  description = "Name of the application"
}

variable "repository_url" {
  description = "ECR repository URL"
  type        = string
}

variable "port" {
  type        = string
  default     = "8080"
  description = "port"
}

variable "cpu" {
  type        = number
  default     = 1024
  description = "cpu"
}

variable "memory" {
  type        = number
  default     = 2048
  description = "memory"
}

resource "aws_apprunner_service" "main" {
  service_name = var.app

  source_configuration {
    auto_deployments_enabled = true

    image_repository {
      image_repository_type = "ECR"
      image_identifier      = "${var.repository_url}:latest"
      image_configuration {
        port = var.port
        runtime_environment_variables = {
          "FOO" = "bar"
        }
      }
    }

    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner.arn
    }
  }

  instance_configuration {
    cpu    = var.cpu
    memory = var.memory
    # instance_role_arn = ""
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/health"
    timeout             = 2
    healthy_threshold   = 1
    interval            = 5
    unhealthy_threshold = 3
  }
}

resource "aws_iam_role" "apprunner" {
  name               = var.app
  assume_role_policy = data.aws_iam_policy_document.apprunner.json

  # workaround for https://github.com/hashicorp/terraform-provider-aws/issues/6566
  provisioner "local-exec" {
    command = "sleep 15"
  }  
}

data "aws_iam_policy_document" "apprunner" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "tasks.apprunner.amazonaws.com",
        "build.apprunner.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "apprunner" {
  role       = aws_iam_role.apprunner.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

output "service_url" {
  value = "https://${aws_apprunner_service.main.service_url}"
}
