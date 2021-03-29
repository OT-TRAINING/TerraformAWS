output "instance_ip_addr" {
  value = aws_instance.main.private_ip
}

output "instance_ip" {
  value = aws_instance.main.public_ip
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}