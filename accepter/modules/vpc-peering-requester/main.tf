provider "aws" {
  alias     = "peer"
  region     = var.PEER_AWS_REGION
}

data "aws_vpc" "peer" {
  provider   = aws.peer
  cidr_block = var.PEER_VPC_CIDR
}

data "aws_caller_identity" "peer" {
  provider = aws.peer
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Name = "${var.USER_ID}-vpc-peering-request-to-${var.PEER_AWS_REGION}"
    Side = "Accepter"
  }
}