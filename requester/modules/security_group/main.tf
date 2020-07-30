## /module/security_group
# ALB security group, security group rule
#------------------------------------------------------------------------------
# ALB security group
locals {
  port_count = length(var.WEB_SERVICE_PORTS)
}

resource "aws_security_group" "alb" {
  count       = local.port_count
  vpc_id      = var.VPC_ID
  
  name        = "${var.USER_ID}_alb_security_group-${var.WEB_SERVICE_PORTS[count.index]}"
  description = "security group that allows http traffic-${var.WEB_SERVICE_PORTS[count.index]}"
  
  tags = {
    Name = "${var.USER_ID}_alb_security_group-${var.WEB_SERVICE_PORTS[count.index]}"
  }
}

# ALB security group rule : TCP PORT 80 IN/OUT만 허용
resource "aws_security_group_rule" "alb_ingress" {
  count             = local.port_count
  type              = "ingress"
  from_port         = var.WEB_SERVICE_PORTS[count.index]
  to_port           = var.WEB_SERVICE_PORTS[count.index]
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb[count.index].id

  lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "alb_egress" {
  count             = local.port_count
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  security_group_id = aws_security_group.alb[count.index].id
  source_security_group_id = aws_security_group.web_server[count.index].id

  lifecycle { create_before_destroy = true }
}

#------------------------------------------------------------------------------
# Web-Server security group
resource "aws_security_group" "web_server" {
  count        = local.port_count
  vpc_id      = var.VPC_ID
  
  name        = "web_server-${var.WEB_SERVICE_PORTS[count.index]}"
  description = "security group that allows ALB http reqeust and response-${var.WEB_SERVICE_PORTS[count.index]}"
  
  tags = {
    Name = "${var.USER_ID}_web_server_security_group-${var.WEB_SERVICE_PORTS[count.index]}"
  }
}

# Web-Server security group rule : ALB와의 IN만 허용
resource "aws_security_group_rule" "web_server_ingress" {
  count             = local.port_count
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  security_group_id = aws_security_group.web_server[count.index].id
  source_security_group_id = aws_security_group.alb[count.index].id

  lifecycle { create_before_destroy = true }
}


resource "aws_security_group_rule" "web_server_egless" {
  count             = local.port_count
  type              = "egress"
  from_port         = var.WEB_SERVICE_PORTS[count.index]
  to_port           = var.WEB_SERVICE_PORTS[count.index]
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_server[count.index].id

  lifecycle { create_before_destroy = true }
}

#------------------------------------------------------------------------------
# ssh security group rule : CI/CD 및 유지보수 관리 목적
resource "aws_security_group" "ssh_maintenance" {
  
  vpc_id      = var.VPC_ID
  
  name        = "ssh_maintenance"
  description = "security group that allows ssh and all egress traffic"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { 
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.SSH_ACCESS_HOST] ## ACCESS_HOST 만 접근
  }
  
  ingress { 
      from_port   = 8
      to_port     = 0
      protocol    = "icmp"
      cidr_blocks = [var.PEER_CIDR]
  }
  
  tags = {
    Name = "${var.USER_ID}_ssh_security_group"
  }
}