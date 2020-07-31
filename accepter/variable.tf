## /

# 전체 서비스 통합 사용자ID
variable "USER_UID" {
	default = "skuser04"
}

# 이 VPC의 사용자ID
variable "USER_ID" {
	default = "skuser04a"
}

# 이 VPC의 리전
variable "AWS_REGION" {
	default = "us-west-1"
}

# 상대편 VPC의 리전
variable "PEER_AWS_REGION" {
	default = "us-west-1"
}

# 인스턴스 접속용 공개키
variable "PATH_TO_PUBLIC_KEY" {
	default = "~/.ssh/id_rsa.pub"
}

# 이 VPC의 CIDR
variable "VPC_CIDR" {
	default = "20.0.0.0/16"
}

# 상대편 VPC의 CIDR
variable "PEER_VPC_CIDR" {
	default = "10.0.0.0/16"
}

# Frontend 서브넷(보통 WEB) 개수
variable "FRONTEND_SUBNET_COUNT" {
	default = 2
}

# Backend 서브넷(보통 WAS/DB) 개수
variable "BACKEND_SUBNET_COUNT" {
	default = 0
}

# Backend 서브넷 활성화 여부
variable "ENABLE_BACKEND_SUBNET" {
	default = false
}

# 인스턴스 접속 호스트IP
variable "SSH_ACCESS_HOST" {
	default = "0.0.0.0/0"
}

# 서비스 포트["80","8080"] 등
variable "WEB_SERVICE_PORTS" {
	default = ["80"]
}

# AMI ID
variable "AMIS" {
	default = {
		us-east-1       = "ami-0e5f76fa1b9ea351b" #북부버지니아
		us-west-1       = "ami-01311df3780ebd33e" #캘리포니아
		us-west-2       = "ami-0e34e7b9ca0ace12d" #오레곤
		eu-west-3       = "ami-08c757228751c5335" #파리
		ap-northeast-2  = "ami-00edfb46b107f643c" #서울
	}
}

# ALB ID
variable "ALB_ACCOUNT_ID" {
	default = {
		us-east-1       = "127311923021" #북부버지니아
		us-west-1       = "027434742980" #캘리포니아
		us-west-2       = "797873946194" #오레곤
		eu-west-3       = "009996457667" #파리
		ap-northeast-2  = "600734575887" #서울
	}
}

variable "PEER_ID" { }