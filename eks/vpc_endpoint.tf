resource "aws_vpc_endpoint" "endpoint_gateway_s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = {
    Name = "endpoint-s3-sam-${terraform.workspace}"
  }
}