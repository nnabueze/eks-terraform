terraform {
    backend "s3" {
    bucket = "s3-terraform-cicd"
    key    = "backend"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.region
}