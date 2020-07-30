locals {
  port_count = length(var.WEB_SERVICE_PORTS)
}

resource "aws_alb" "alb" {
  count       = local.port_count

  name = "${var.USER_ID}-alb-${var.WEB_SERVICE_PORTS[count.index]}"
  internal = false
  subnets = var.ALB_AUTO_SCALING_SUBNETS
  security_groups = [var.ALB_SECURITY_GROUPS[count.index].id]

  lifecycle { 
    create_before_destroy = true 
  }

  tags = {
    Name = "${var.USER_ID}-alb-${var.WEB_SERVICE_PORTS[count.index]}"
  }
  
}

resource "aws_alb_target_group" "target_group" {
    count       = local.port_count

    name = "${var.USER_ID}-alb-target-group-${var.WEB_SERVICE_PORTS[count.index]}"
    port = 80
    protocol = "HTTP"
    vpc_id = var.VPC_ID
    
    health_check {
        interval = 30
        path = "/"
        healthy_threshold = 3
        unhealthy_threshold = 3
    }   

    tags = { 
        Name = "${var.USER_ID}-alb-target-group-${var.WEB_SERVICE_PORTS[count.index]}" 
    }
}

# autoscaling이 아닌 instance 대상일 경우
# resource "aws_alb_target_group_attachment" "attach-targets" {
#     # count = var.WEB_SERVER_COUNT
#     target_group_arn = aws_alb_target_group.targets.arn
#     # target_id = aws_instance.web-server[0].id
#     target_id = aws_autoscaling_group.webserver-autoscaling.id
#     port = 80
# }

resource "aws_alb_listener" "listener" {
    count       = local.port_count

    load_balancer_arn = aws_alb.alb[count.index].arn
    port = var.WEB_SERVICE_PORTS[count.index]
    protocol = "HTTP"
    default_action {
        target_group_arn = aws_alb_target_group.target_group[count.index].arn
        type = "forward"
    }
}


resource "aws_launch_configuration" "launchconfig" {
  count                = local.port_count
  name_prefix          = "${var.USER_ID}-launchconfig-${var.WEB_SERVICE_PORTS[count.index]}"
  image_id             = var.INSTANCE_IMAGE_ID
  instance_type        = var.INSTANCE_TYPE
  key_name             = var.PUBLIC_KEY_NAME
  security_groups      = [var.WEB_SECURITY_GROUPS[count.index].id,var.SSH_SECURITY_GROUP]
  lifecycle {
    create_before_destroy = true
  }

  # user data에서 자동으로 cloudfront 이미지 주소와 사설 IP 할당
  user_data = <<EOF
    #!/bin/bash
    timedatectl set-timezone Asia/Seoul
    sudo yum update
    sudo yum install -y curl
    sudo yum install -y httpd
    sudo echo "Hostname : <b>$(hostname)</b><br>" >> /var/www/html/index.html
    sudo echo "Region : ${var.AWS_REGION}<br>" >> /var/www/html/index.html
    sudo echo "Create Time : $(date +%Y'-'%m'-'%d' '%H':'%M':'%S)<br>" >> /var/www/html/index.html
    sudo echo "<img src=${var.CDN_IMAGE_URI}>" >> /var/www/html/index.html
    sudo systemctl enable httpd
    sudo systemctl start httpd
	EOF
}

resource "aws_autoscaling_group" "scaling_group" {
  count                     = local.port_count
  name                      = "${var.USER_ID}_scaling_group-${var.WEB_SERVICE_PORTS[count.index]}"
  vpc_zone_identifier       = var.ALB_AUTO_SCALING_SUBNETS
  launch_configuration      = aws_launch_configuration.launchconfig[count.index].id
  min_size                  = var.AUTO_SCALE_MIN_SIZE
  desired_capacity          = var.DESIRED_CAPACITY
  max_size                  = var.AUTO_SCALE_MAX_SIZE
  health_check_grace_period = 300
  health_check_type         = "ELB"  # ALBRequestCountPerTarget
  #health_check_type        = "EC2"  # ASGAverageCPUUtilization
  force_delete = true

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity="1Minute"

  tag {
      key = "Name"
      value = "${var.USER_ID}-alb-autoscaling-instance-${var.WEB_SERVICE_PORTS[count.index]}"
      propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scaling_policy" {
  count                     = local.port_count
  name                      = "${var.USER_ID}-tracking-policy-${var.WEB_SERVICE_PORTS[count.index]}"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.scaling_group[count.index].name
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      #predefined_metric_type = "ASGAverageCPUUtilization"
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${aws_alb.alb[count.index].arn_suffix}/${aws_alb_target_group.target_group[count.index].arn_suffix}"
      #issue solved: https://github.com/terraform-providers/terraform-provider-aws/issues/9734
    }
    
    #target_value = "10" #ASGAverageCPUUtilization CPU 10%
    target_value = "1" #ALBRequestCountPerTarget Request 1
  }
}

resource "aws_autoscaling_attachment" "attachment" {
  count                 = local.port_count
  alb_target_group_arn   = aws_alb_target_group.target_group[count.index].arn
  autoscaling_group_name = aws_autoscaling_group.scaling_group[count.index].id
}
