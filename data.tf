# Retrieving the number of az available
data "aws_availability_zones" "az-available" {}

data "aws_s3_bucket" "selected" {
  bucket = "s3-terraform-cicd"
}