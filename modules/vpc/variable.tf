## /module/vpc

variable "VPC_CIDR" { }

variable "FRONTEND_SUBNET_COUNT" { }

variable "BACKEND_SUBNET_COUNT" { }

variable "ENABLE_BACKEND_SUBNET" { }

variable "USER_ID" { }

#variable "PEER_ID" {
#    default = "pcx-0fd48d0b95feffd35"
#}

#variable "PEER_CIDR" {
#    default = "10.0.0.0/16"
#}