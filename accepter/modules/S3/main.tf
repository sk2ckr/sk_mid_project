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
  content_type = "image/jpg"
}