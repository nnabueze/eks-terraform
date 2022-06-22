terraform {
    backend "s3" {
    bucket = "s3-terraform-cicd"
    key    = "backend/terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.region
}