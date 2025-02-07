output "vpc_id" {
  value = aws_vpc.q1_VPC.id
}

output "q1-PublicSubnet" {
  value = aws_subnet.q1_PublicSubnet.id
}

output "q1-PrivateSubnet" {
  value = aws_subnet.q1_PrivateSubnet.id
}