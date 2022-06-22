##################
# Route53
#################
# Create a hosted zone
resource "aws_route53_zone" "primary" {
  name = var.hosted-zone
  comment = "${var.hosted-zone} public zone"

  vpc {
    vpc_id = aws_vpc.aws-vpc.id
  }
}

