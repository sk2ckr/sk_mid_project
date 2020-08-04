# 서비스 사용자ID
variable "USER_UID" {
	default = "skuser300"
}

# Requester VPC의 사용자ID
variable "REQUESTER_USER_ID" {
	default = "skuser301"
}

# Accepter VPC의 사용자ID
variable "ACCEPTER_USER_ID" {
	default = "skuser302"
}

# Requester VPC의 리전
variable "REQUESTER_AWS_REGION" {
	default = "us-west-1"
}

# Accepter VPC의 리전
variable "ACCEPTER_AWS_REGION" {
	default = "us-east-1"
}

# 인스턴스 접속용 공개키
variable "PATH_TO_PUBLIC_KEY" {
	default = "~/.ssh/id_rsa.pub"
}

# 이 VPC의 CIDR
variable "REQUESTER_VPC_CIDR" {
	default = "10.0.0.0/16"
}

# 상대편 VPC의 CIDR
variable "ACCEPTER_VPC_CIDR" {
	default = "20.0.0.0/16"
}

# Frontend 서브넷(보통 WEB) 개수
variable "FRONTEND_SUBNET_COUNT" {
	default = 2
}

# Backend 서브넷(보통 WAS/DB) 개수
variable "BACKEND_SUBNET_COUNT" {
	default = 2
}

# Backend 서브넷 활성화 여부
variable "ENABLE_BACKEND_SUBNET" {
	default = true
}

# 인스턴스 접속 호스트IP
variable "SSH_ACCESS_HOST" {
	default = "0.0.0.0/0"
}

# 서비스 포트["80","8080"] 등
variable "WEB_SERVICE_PORTS" {
	default = ["80", "8080"]
}

# S3 Object Name
variable "BUCKET_OBJECT" {
    default = "images/perfect.jpg"
}

# AMI ID
variable "AMIS" {
	default = {
		us-east-1       = "ami-0e5f76fa1b9ea351b" #북부버지니아
		us-east-2		= "ami-07c8bc5c1ce9598c3" #오하이오
		us-west-1       = "ami-01311df3780ebd33e" #캘리포니아
		us-west-2       = "ami-0873b46c45c11058d" #오레곤
		ap-northeast-2  = "ami-0bd7691bf6470fe9c" #서울
		ap-southeast-1	= "ami-02f3b237d55fc8691" #싱가포르
		eu-central-1	= "ami-096c1922a7e55b3b0" #프랑크푸르트
	}
}

# ALB ID
variable "ALB_ACCOUNT_ID" {
	default = {
		us-east-1       = "127311923021" #북부버지니아
		us-east-2		= "033677994240" #오하이오
		us-west-1       = "027434742980" #캘리포니아
		us-west-2       = "797873946194" #오레곤
		ap-northeast-2  = "600734575887" #서울
		ap-southeast-1	= "114774131450" #싱가포르
		eu-central-1	= "054676820928" #프랑크푸르트
	}
}

# 호스팅 영역 ID
variable "HOSTED_ZONE_ID" {
  default = "Z0862536T5BGO77G0AIM"
}

variable "DOMAIN_NAME" {
  default = "aws-test.cf"
}

#ALB생성 Region에 따른 A-record가 geo routing할 대상 대륙 지정 
variable "REQUESTER_CONTINENT" {
  default = ["NA", "AF", "AN", "EU"]
}

variable "ACCEPTER_CONTINENT" {
  default = ["SA", "AS", "OC"]
}

# eu-west-03
# AF: Africa
# AN: Antarctica
# EU: Europe
# OC: Oceania

# us-west-01
# AS: Asia
# NA: North America
# SA: South America  
