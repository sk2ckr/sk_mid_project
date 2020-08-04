output "vpc_peering_id" {
    value = aws_vpc_peering_connection.peer.id
}

output "images_cdn" {
    value = aws_cloudfront_distribution.images_cdn.domain_name
}