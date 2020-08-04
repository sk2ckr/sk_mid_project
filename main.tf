provider "aws" {
  region    = var.REQUESTER_AWS_REGION
}

module "common" {

  source                    = "./common"
  
  USER_UID                  = var.USER_UID
  REQUESTER_VPC_ID          = module.requester.vpc_id
  ACCEPTER_VPC_ID           = module.accepter.vpc_id
  REQUESTER_AWS_REGION      = var.REQUESTER_AWS_REGION
  ACCEPTER_AWS_REGION       = var.ACCEPTER_AWS_REGION
  BUCKET_OBJECT             = var.BUCKET_OBJECT
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
  PEER_ID                   = module.common.vpc_peering_id
  #IMAGE_URI                 = "http://${aws_s3_bucket.images_bucket.bucket_regional_domain_name}/${aws_s3_bucket_object.images_object.key}"
  IMAGE_URI                 = "https://${module.common.images_cdn}"
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
  PEER_ID                   = module.common.vpc_peering_id
  #IMAGE_URI                 = "http://${aws_s3_bucket.images_bucket.bucket_regional_domain_name}/${aws_s3_bucket_object.images_object.key}"
  IMAGE_URI                 = "https://${module.common.images_cdn}"
}

