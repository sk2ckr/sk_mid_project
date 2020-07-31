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

resource "aws_vpc_peering_connection" "peer" {
  provider      = aws.peer
  vpc_id        = var.VPC_ID

  peer_vpc_id   = data.aws_vpc.peer.id
  peer_owner_id = data.aws_caller_identity.peer.account_id
  peer_region   = var.PEER_AWS_REGION
  auto_accept   = false # 모든 resource에 provider코드를 중복 작성하지 않으면 false만 됨

  tags = {
    Name = "${var.USER_ID}-vpc-peering-request-to-${var.PEER_AWS_REGION}"
    Side = "Requester"
  }
}
