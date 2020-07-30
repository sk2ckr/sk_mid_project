output "s3_object_uri" {
#  value       = format("http://%s/%s", 
#                        aws_cloudfront_distribution.images_cdn.domain_name,
#                        aws_s3_bucket_object.images_cdn.key)
#  value       = format("http://%s", aws_s3_bucket_object.images_cdn.key)
  value         = format("http://sk-mid-project.s3.ap-northeast-2.amazonaws.com/img/perfect.jpg")
}

#output "cloudfront_domain_name" {
#  value       = aws_cloudfront_distribution.images_cdn.domain_name
#}