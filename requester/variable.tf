## /

# 전체 서비스 통합 사용자ID
variable "USER_UID" {
}

# 이 VPC의 사용자ID
variable "USER_ID" {
}

# 이 VPC의 리전
variable "AWS_REGION" {
}

# 상대편 VPC의 리전
variable "PEER_AWS_REGION" {
}

# 인스턴스 접속용 공개키
variable "PATH_TO_PUBLIC_KEY" {
}

# 이 VPC의 CIDR
variable "VPC_CIDR" {
}

variable "PEER_ID" {
}

# 상대편 VPC의 CIDR
variable "PEER_VPC_CIDR" {
}

# Frontend 서브넷(보통 WEB) 개수
variable "FRONTEND_SUBNET_COUNT" {
}

# Backend 서브넷(보통 WAS/DB) 개수
variable "BACKEND_SUBNET_COUNT" {
}

# Backend 서브넷 활성화 여부
variable "ENABLE_BACKEND_SUBNET" {
}

# 인스턴스 접속 호스트IP
variable "SSH_ACCESS_HOST" {
}

# 서비스 포트["80","8080"] 등
variable "WEB_SERVICE_PORTS" {
}

variable "IMAGE_URI" {
}

# AMI ID
variable "AMIS" {
}

# ALB ID
variable "ALB_ACCOUNT_ID" {
}

# DNS 호스팅 영역
variable "HOSTED_ZONE_ID" {
}

# 도메인 이름
variable "DOMAIN_NAME" {
}

# 지오라우팅 영역
variable "CONTINENT" {
}

