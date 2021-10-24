output "security_group_id" {
  description = "The Bastion Security Group ID"
  value       = aws_security_group.bastion_sg.id
}

output "key_name" {
  description = "The key name that should be used for the instance."
  value       = aws_key_pair.bastion_key.key_name
}

output "public_ip" {
  description = "Public IP addresses of instances found through the filter"
  value       = data.aws_instances.bastion_instances.public_ips
}