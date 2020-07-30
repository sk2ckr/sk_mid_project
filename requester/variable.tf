## /

variable "USER_UID" {
  default = "skuser04"
}

variable "USER_ID" {
  default = "skuser04r"
}

variable "AWS_REGION" {
  default = "us-west-1"
}

variable "PEER_AWS_REGION" {
  default = "us-west-1"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "~/.ssh/id_rsa.pub"
}

variable "VPC_CIDR" {
  default = "10.0.0.0/16"
}

variable "PEER_VPC_CIDR" {
  default = "20.0.0.0/16"
}

variable "FRONTEND_SUBNET_COUNT" {
  default = 2
}

variable "BACKEND_SUBNET_COUNT" {
  default = 0
}

variable "ENABLE_BACKEND_SUBNET" {
  default = false
}

variable "SSH_ACCESS_HOST" {
  default = "54.158.38.87/32"
}

variable "WEB_SERVICE_PORTS" {
  default = ["80"]
}

variable "AMIS" {
  default = {
    us-east-1       = "ami-0e5f76fa1b9ea351b" #북부버지니아
    us-west-1       = "ami-01311df3780ebd33e" #캘리포니아
    us-west-2       = "ami-0e34e7b9ca0ace12d" #오레곤
    eu-west-3       = "ami-08c757228751c5335" #파리
    ap-northeast-2  = "ami-00edfb46b107f643c" #서울
  }
}

variable "ALB_ACCOUNT_ID" {
  default = {
    us-east-1       = "127311923021" #북부버지니아
    us-west-1       = "027434742980" #캘리포니아
    us-west-2       = "797873946194" #오레곤
    eu-west-3       = "009996457667" #파리
    ap-northeast-2  = "600734575887" #서울
  }
}
