data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

variable "project_slug" {
  default = "step-machine"
}

# For use in resource tagging
variable "environment" {}
variable "reseller" {}
variable "project" {
  default = "Step Machine Example"
}

variable "env" {}

variable "python_version" {
  default = "3.7"
}

variable "hashing_lambda_filepath" {
  default = "../../lambda/hashing"
}

variable "deployment_package_name" {
  default = "lambda.zip"
}

variable "lambda_timeout" {
  default = "30"
}

locals {
  common_tags = {
    Project     = var.project
    Reseller    = var.reseller
    Environment = var.environment
  }
}
