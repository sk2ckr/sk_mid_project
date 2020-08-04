provider "aws" {
  region    = var.REQUESTER_AWS_REGION
}

####################################################################
## VPC Peering                                                    ##
####################################################################

## VPC Peering (Two Region) ########################################
provider "aws" {
  alias  = "peer"
  region = var.ACCEPTER_AWS_REGION

  # Accepter's credentials.
}

data "aws_caller_identity" "peer" {
  provider = aws.peer
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = var.REQUESTER_VPC_ID
  peer_vpc_id   = var.ACCEPTER_VPC_ID
  peer_owner_id = data.aws_caller_identity.peer.account_id
  peer_region   = var.ACCEPTER_AWS_REGION
  auto_accept   = false

  tags = {
    Side = "Requester"
    Name = "${var.USER_UID}-VPC-Peering"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
    Name = "${var.USER_UID}-VPC-Peering"
  }
}
####################################################################

## VPC Peering (One Region) ########################################
/*
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = module.accepter.vpc_id
  vpc_id        = module.requester.vpc_id

  auto_accept   = true
  
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "${var.USER_UID}-VPC-Peering"
    Managed_by  = "terraform"
  }
}
*/

####################################################################
## S3, Cloudfront                                                 ##
####################################################################

# S3 bucket 접근 정책 생성
data "aws_iam_policy_document" "images_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::skcc-${var.USER_UID}-web-images/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.access_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::skcc-${var.USER_UID}-web-images"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.access_identity.iam_arn]
    }
  }
}

# S3 bucket 생성
resource "aws_s3_bucket" "images_bucket" {
  bucket = "skcc-${var.USER_UID}-web-images"
  acl    = "private"

  force_destroy = "true"
  
  tags = {
    Name = "skcc-${var.USER_UID}-web-images"
  }
}

# S3 Object 생성
resource "aws_s3_bucket_object" "images_object" {
  bucket = aws_s3_bucket.images_bucket.id
  key    = var.BUCKET_OBJECT
  source = "./common/${var.BUCKET_OBJECT}"
  content_type = "image/jpg"
  #acl    = "public-read"
}

# S3 bucket과 접근 정책 연결
resource "aws_s3_bucket_policy" "images_bucket_policy" {
  bucket = aws_s3_bucket.images_bucket.id
  policy = data.aws_iam_policy_document.images_bucket_policy.json
}

# origin access identity 생성
resource "aws_cloudfront_origin_access_identity" "access_identity" {
  comment = "${var.USER_UID}_origin_access_identity"
}

# Cloudfront 생성
resource "aws_cloudfront_distribution" "images_cdn" {

  origin {
    domain_name = aws_s3_bucket.images_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.images_bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.access_identity.cloudfront_access_identity_path
    }
  }

  comment = "${var.USER_UID}_images_cdn"
  
  enabled             = true
  is_ipv6_enabled     = true
  wait_for_deployment = false #cloudfront status가 deployed전 먼저 terraform apply completed
  default_root_object = var.BUCKET_OBJECT
  price_class         = "PriceClass_All"


  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.images_bucket.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # 지역별 허용시
      # restriction_type = "whitelist"
      # locations        = ["KR", "US", "CA", "GB", "DE"]
  }
  }

  tags = {
    Name = format("%s-cloudfront", var.USER_UID)
  }
}