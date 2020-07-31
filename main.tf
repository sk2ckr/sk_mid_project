provider "aws" {
  region    = "us-west-1"
}

provider "aws" {
  alias     = "peer"
  region    = "us-west-1"
}

resource "aws_key_pair" "public_key" {
  provider      = aws.peer

  key_name   = "${var.USER_UID}_public_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
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
    IMAGE_URI                 = var.IMAGE_URI
    KEY_NAME                  = aws_key_pair.public_key.key_name
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
    PEER_ID                   = aws_vpc_peering_connection_accepter.peer.id
    IMAGE_URI                 = var.IMAGE_URI
    KEY_NAME                  = aws_key_pair.public_key.key_name
  
}

####################################################################
## S3 생성                                                        ##
####################################################################

data "aws_caller_identity" "peer" {}

resource "aws_vpc_peering_connection" "peer" {
  provider      = aws.peer
  vpc_id        = module.requester.vpc_id

  peer_vpc_id   = module.accepter.vpc_id
  peer_owner_id = data.aws_caller_identity.peer.account_id
  peer_region   = var.ACCEPTER_AWS_REGION
  auto_accept   = false

  tags = {
    Name = "Requester"
    Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = false

  tags = {
    Name = "Accepter"
    Side = "Accepter"
  }
}

####################################################################
## S3 Object 생성                                                 ##
####################################################################

# priavate ACL S3 bucket 생성
resource "aws_s3_bucket" "images_bucket" {
  provider      = aws.peer

  bucket = "skcc-${var.USER_UID}-web-images"
  acl    = "private"

  force_destroy = "true"
  
  tags = {
    Name = "skcc-${var.USER_UID}-web-images"
  }
}

# Upload S3 bucket Object
resource "aws_s3_bucket_object" "images_object" {
  provider      = aws.peer

  bucket = aws_s3_bucket.images_bucket.id
  key    = "images/perfect.jpg"
  source = "./images/perfect.jpg"
  content_type = "image/jpg"
  acl    = "public-read"
}

output "s3_object_uri" {
  value       = format("http://%s", aws_s3_bucket_object.images_object.key)
}