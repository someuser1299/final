

output "instance_ip" {
  value = aws_instance.builder.public_ip
}

output "instance_id" {
  value = aws_instance.builder.id
}

