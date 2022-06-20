##########################
# Security group
#########################

resource "aws_security_group" "eks-node-sg" {
    name        = "${var.app_name}-eks-node-sg"
    description = "security group for eks workers node"
    vpc_id      = aws_vpc.aws-vpc.id

    # Inbound Rules
    # HTTP access from anywhere
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Outbound Rules
    # Internet access to anywhere
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


