output "public_ip" {
  description = "Public IP for the Bastion"
  value       = aws_instance.bastion.public_ip
}

output "security_group_id" {
  description = "The Bastion Security Group ID"
  value       = aws_security_group.bastion_sg.id
}

output "key_name" {
  description = "The key name that should be used for the instance."
  value       = aws_key_pair.bastion_key.key_name
}