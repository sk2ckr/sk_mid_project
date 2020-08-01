provider "aws" {
  region    = var.REQUESTER_AWS_REGION
}

module "accepter" {

    source                    = "./accepter"
    
    USER_UID                  = var.USER_UID
    USER_ID                   = var.ACCEPTER_USER_ID
    AWS_REGION                = var.ACCEPTER_AWS_REGION
    PEER_AWS_REGION           = var.REQUESTER_AWS_REGION
    PATH_TO_PUBLIC_KEY        = var.PATH_TO_PUBLIC_KEY
    VPC_CIDR                  = var.ACCEPTER_VPC_CIDR
    PEER_VPC_CIDR             = var.REQUESTER_VPC_CIDR
    FRONTEND_SUBNET_COUNT     = var.FRONTEND_SUBNET_COUNT
    BACKEND_SUBNET_COUNT      = var.BACKEND_SUBNET_COUNT
    ENABLE_BACKEND_SUBNET     = var.ENABLE_BACKEND_SUBNET
    SSH_ACCESS_HOST           = var.SSH_ACCESS_HOST
    WEB_SERVICE_PORTS         = var.WEB_SERVICE_PORTS
    AMIS                      = var.AMIS
    ALB_ACCOUNT_ID            = var.ALB_ACCOUNT_ID
    PEER_ID                   = aws_vpc_peering_connection.peer.id
    IMAGE_URI                 = "http://${aws_s3_bucket.images_bucket.bucket_regional_domain_name}/${aws_s3_bucket_object.images_object.key}"
}

module "requester" {

    source  = "./requester"
    
    USER_UID                  = var.USER_UID
    USER_ID                   = var.REQUESTER_USER_ID
    AWS_REGION                = var.REQUESTER_AWS_REGION
    PEER_AWS_REGION           = var.ACCEPTER_AWS_REGION
    PATH_TO_PUBLIC_KEY        = var.PATH_TO_PUBLIC_KEY
    VPC_CIDR                  = var.REQUESTER_VPC_CIDR
    PEER_VPC_CIDR             = var.ACCEPTER_VPC_CIDR
    FRONTEND_SUBNET_COUNT     = var.FRONTEND_SUBNET_COUNT
    BACKEND_SUBNET_COUNT      = var.BACKEND_SUBNET_COUNT
    ENABLE_BACKEND_SUBNET     = var.ENABLE_BACKEND_SUBNET
    SSH_ACCESS_HOST           = var.SSH_ACCESS_HOST
    WEB_SERVICE_PORTS         = var.WEB_SERVICE_PORTS
    AMIS                      = var.AMIS
    ALB_ACCOUNT_ID            = var.ALB_ACCOUNT_ID
    PEER_ID                   = aws_vpc_peering_connection.peer.id
    IMAGE_URI                 = "http://${aws_s3_bucket.images_bucket.bucket_regional_domain_name}/${aws_s3_bucket_object.images_object.key}"
}

####################################################################
## Common Resourse                                                ##
####################################################################

## VPC Peering (Two Region) ########################################
provider "aws" {
  alias  = "peer"
  region = var.ACCEPTER_AWS_REGION

  # Accepter's credentials.
}

data "aws_caller_identity" "peer" {
  provider = aws.peer
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = module.requester.vpc_id
  peer_vpc_id   = module.accepter.vpc_id
  peer_owner_id = data.aws_caller_identity.peer.account_id
  peer_region   = var.ACCEPTER_AWS_REGION
  auto_accept   = false

  tags = {
    Side = "Requester"
    Name = "${var.USER_UID}-VPC-Peering"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
    Name = "${var.USER_UID}-VPC-Peering"
  }
}
####################################################################

## VPC Peering (One Region) ########################################
/*
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = module.accepter.vpc_id
  vpc_id        = module.requester.vpc_id

  auto_accept   = true
  
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "${var.USER_UID}-VPC-Peering"
    Managed_by  = "terraform"
  }
}
*/
####################################################################

## S3 bucket, S3 Object

resource "aws_s3_bucket" "images_bucket" {
  bucket = "skcc-${var.USER_UID}-web-images"
  acl    = "private"

  force_destroy = "true"
  
  tags = {
    Name = "skcc-${var.USER_UID}-web-images"
  }
}

resource "aws_s3_bucket_object" "images_object" {
  bucket = aws_s3_bucket.images_bucket.id
  key    = "images/perfect.jpg"
  source = "./common/images/perfect.jpg"
  content_type = "image/jpg"
  acl    = "public-read"
}
