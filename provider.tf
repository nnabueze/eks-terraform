terraform {
    backend "s3" {
    bucket = data.aws_s3_bucket.selected.id
    key    = "backend"
    region = var.region
  }
}

provider "aws" {
  region = var.region
}