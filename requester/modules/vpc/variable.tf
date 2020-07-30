## /module/vpc

variable "VPC_CIDR" { }

variable "FRONTEND_SUBNET_COUNT" { }

variable "BACKEND_SUBNET_COUNT" { }

variable "ENABLE_BACKEND_SUBNET" { }

variable "USER_ID" { }

variable "PEER_ID" {
    default = "pcx-0f47f2201e82c4be7"
}

variable "PEER_CIDR" {
    #default = "10.0.0.0/16"
}