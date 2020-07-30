## /

provider "aws" {
#  access_key = var.AWS_ACCESS_KEY
#  secret_key = var.AWS_SECRET_KEY
  region     = var.AWS_REGION
}

resource "aws_key_pair" "public_key" {
  key_name   = "${var.USER_ID}_public_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

module "vpc" {
    
    source                      = "./modules/vpc" 
    
    VPC_CIDR                    = var.VPC_CIDR
    FRONTEND_SUBNET_COUNT       = var.FRONTEND_SUBNET_COUNT
    BACKEND_SUBNET_COUNT        = var.BACKEND_SUBNET_COUNT
    ENABLE_BACKEND_SUBNET       = var.ENABLE_BACKEND_SUBNET
    USER_ID                     = var.USER_ID

    #VPC-Peer할 때만 활성화 할 것
#    PEER_CIDR                   = var.PEER_VPC_CIDR
#    PEER_ID                     = local.peering_id
}

module "security_group_policy" {
    
    source                      = "./modules/security_group" 
    
    VPC_ID                      = module.vpc.id
    WEB_SERVICE_PORTS           = var.WEB_SERVICE_PORTS #80,8080
    SSH_ACCESS_HOST             = var.SSH_ACCESS_HOST
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
    ALB_LOG_BUCKET_NAME         = "${var.USER_ID}-alb-log-${var.AWS_REGION}"
    ALB_ACCOUNT_ID              = lookup(var.ALB_ACCOUNT_ID, var.AWS_REGION)

    # instance templete config
    INSTANCE_IMAGE_ID           = lookup(var.AMIS, var.AWS_REGION)
    INSTANCE_TYPE               = "t2.micro"
    WEB_SECURITY_GROUPS         = module.security_group_policy.web_server_sgs
    SSH_SECURITY_GROUP          = module.security_group_policy.ssh_sgi
    PUBLIC_KEY_NAME             = aws_key_pair.public_key.key_name
    CDN_IMAGE_URI               = module.web_images_cdn.s3_object_uri #인라인으로 배포
    AWS_REGION                  = var.AWS_REGION  #인라인으로 배포
    
    # for auto-scaling-group
    AUTO_SCALE_MIN_SIZE         = 1
    AUTO_SCALE_MAX_SIZE         = 3
    DESIRED_CAPACITY            = 2

    # for tagging
    USER_ID                 = var.USER_ID

}
/* 라우드53 비활성
module "route53" { 
    
    source                      = "./modules/route53" 

    HOSTED_ZONE_ID              = var.HOSTED_ZONE_ID
    
    ALBS                        = module.alb_auto_scaling.alb
    WEB_SERVICE_PORTS           = var.WEB_SERVICE_PORTS
    # ALB_DNS_NAME                = module.alb_auto_scaling.alb_domain_name
    # ALB_ZONE_ID                 = module.alb_auto_scaling.alb_zone_id
    
    AWS_REGION                  = var.AWS_REGION
    USER_ID                 = var.USER_ID

    DOMAIN_NAME                 = var.DOMAIN_NAME
    CONTINENT                   = var.CONTINENT #geo routing policy to routing53
}
*/
module "web_images_cdn" { #cloudfront
    
    source                      = "./modules/cloudfront" 

    IMAGES_BUCKET_NAME          = "${var.USER_ID}-web-images-${var.AWS_REGION}-sk2"
    BUCKET_OBJECT               = "images/iu.gif"
    LOG_BUCKET_NAME             = "${var.USER_ID}-cf-log-${var.AWS_REGION}-sk2"
    USER_ID                 = var.USER_ID

}

# [주의!] 
# 0. 동일 코드를 두개의 폴더로 분리 peer1, peer2
# 1. peer2는 vpc_peering모듈X, vpc일부 코드 실행차단, variables.tf 수정
# 2. peer2 리전의 VPC 및 구성을 먼저 생성후
# 3. 아래 코드 활성화후 peer1 수행
# 4. terraform apply : peer1은 자동으로 완료
# 5. peer2 리전에서 수동으로 accept 수행
# 6. peer2 vpc추가 코드 활성화후 다시 적용 
/*
module "vpc_peering_requester" { //accepter는 실행하지 말것!!!
    
    source                      = "./modules/vpc-peering-requester" 
    
    AWS_ACCESS_KEY              = var.AWS_ACCESS_KEY
    AWS_SECRET_KEY              = var.AWS_SECRET_KEY
    VPC_ID                      = module.vpc.id
    
    PEER_AWS_REGION             = var.PEER_AWS_REGION
    PEER_VPC_CIDR               = var.PEER_VPC_CIDR
    
    USER_ID                 = var.USER_ID
}
output "peering_id" {
  value = module.vpc_peering_requester.id
}
*/
