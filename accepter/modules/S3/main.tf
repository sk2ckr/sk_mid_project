###############################################################################
# private ACL S3 생성 및 cloudfront 읽기 권한 설정
###############################################################################
#data "aws_iam_policy_document" "images_cdn" {
#  statement {
#    actions   = ["s3:GetObject"]
#    resources = ["arn:aws:s3:::${var.IMAGES_BUCKET_NAME}/*"]

#    principals {
#      type        = "AWS"
#      identifiers = ["${aws_cloudfront_origin_access_identity.images_cdn.iam_arn}"]
#    }
#  }

#  statement {
#    actions   = ["s3:ListBucket"]
#    resources = ["arn:aws:s3:::${var.IMAGES_BUCKET_NAME}"]

#    principals {
#      type        = "AWS"
#      identifiers = ["${aws_cloudfront_origin_access_identity.images_cdn.iam_arn}"]
#    }
#  }
#}

# priavate ACL S3 bucket 생성
resource "aws_s3_bucket" "images_cdn" {
  bucket = var.IMAGES_BUCKET_NAME
  acl    = "private"

  force_destroy = "true"

  tags = {
    Name = var.IMAGES_BUCKET_NAME
  }
}

# Upload S3 bucket Object
resource "aws_s3_bucket_object" "images_cdn" {
  bucket = aws_s3_bucket.images_cdn.id
  key    = var.BUCKET_OBJECT
  source = "./${var.BUCKET_OBJECT}"
  content_type = "image/gif"
}

# S3 bucket과 접근 policy 연결
#resource "aws_s3_bucket_policy" "images_cdn" {
#  bucket = aws_s3_bucket.images_cdn.id
#  policy = data.aws_iam_policy_document.images_cdn.json
#}

# origin access identity 생성
#resource "aws_cloudfront_origin_access_identity" "images_cdn" {
#  comment = "${var.USER_ID}_origin_access_identity"
#}