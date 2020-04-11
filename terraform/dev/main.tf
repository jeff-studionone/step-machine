provider "aws" {
  region  = "ap-southeast-2"
  version = ">= 2.4.0"
}

# You will need this bucket already running in you env
terraform {
  backend "s3" {
    key    = "step-machine/dev.tfstate"
    bucket = "example-terraform-events-storage"
    region = "ap-southeast-2"
  }
}

module "deployment" {
  source   = "../terraform-module"
  env      = "dev"
  reseller = "Example"

  # For use in resource tagging
  environment = "Development"
}

