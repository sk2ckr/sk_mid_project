output "s3_object_uri" {
  value       = format("http://%s", aws_s3_bucket_object.images_cdn.key)
}