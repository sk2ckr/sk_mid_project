## /

provider "aws" {
  region     = var.AWS_REGION
}

resource "aws_key_pair" "public_key" {
  key_name   = "${var.USER_ID}_public_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

module "vpc" {
    
    source                      = "./modules/vpc" 
    
    AWS_REGION                  = var.AWS_REGION
    VPC_CIDR                    = var.VPC_CIDR
    FRONTEND_SUBNET_COUNT       = var.FRONTEND_SUBNET_COUNT
    BACKEND_SUBNET_COUNT        = var.BACKEND_SUBNET_COUNT
    ENABLE_BACKEND_SUBNET       = var.ENABLE_BACKEND_SUBNET
    USER_ID                     = var.USER_ID

    #VPC-Peer할 때만 활성화 할 것
    PEER_CIDR                   = var.PEER_VPC_CIDR
    PEER_ID                     = var.PEER_ID
}

module "security_group_policy" {
    
    source                      = "./modules/security_group" 
    
    VPC_ID                      = module.vpc.id
    WEB_SERVICE_PORTS           = var.WEB_SERVICE_PORTS #80,8080
    SSH_ACCESS_HOST             = var.SSH_ACCESS_HOST
    PEER_CIDR                   = var.PEER_VPC_CIDR
    USER_ID                     = var.USER_ID
}

module "alb_auto_scaling" {
    
    source                      = "./modules/alb_autoscaling" 

    //사용포트지정
    WEB_SERVICE_PORTS           = var.WEB_SERVICE_PORTS

    # for ALB
    VPC_ID                      = module.vpc.id
    ALB_AUTO_SCALING_SUBNETS    = [for s in module.vpc.frontend_subnets : s.id]
    ALB_SECURITY_GROUPS         = module.security_group_policy.alb_sgs
    ALB_ACCOUNT_ID              = lookup(var.ALB_ACCOUNT_ID, var.AWS_REGION)

    # instance templete config
    INSTANCE_IMAGE_ID           = lookup(var.AMIS, var.AWS_REGION)
    INSTANCE_TYPE               = "t2.micro"
    WEB_SECURITY_GROUPS         = module.security_group_policy.web_server_sgs
    SSH_SECURITY_GROUP          = module.security_group_policy.ssh_sgi
    PUBLIC_KEY_NAME             = aws_key_pair.public_key.key_name
    IMAGE_URI                   = var.IMAGE_URI
    AWS_REGION                  = var.AWS_REGION  #인라인으로 배포
    
    # for auto-scaling-group
    AUTO_SCALE_MIN_SIZE         = 1
    AUTO_SCALE_MAX_SIZE         = 4
    DESIRED_CAPACITY            = 2

    # for tagging
    USER_ID                 = var.USER_ID
    
}