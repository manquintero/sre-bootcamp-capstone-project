output "alb_dns_name" {
  value       = aws_lb.application.dns_name
  description = "The domain name of the load balancer"
}

output "alg_security_group_id" {
  value       = aws_security_group.alb.id
  description = "The ID of the Security Group  attached to the load balancer"
}