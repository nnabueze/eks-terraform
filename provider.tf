terraform {
    backend "s3" {
    bucket = data.aws_s3_bucket.selected.id
    key    = "backend"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.region
}