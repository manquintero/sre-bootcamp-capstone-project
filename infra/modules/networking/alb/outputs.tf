output "alb_dns_name" {
  value       = aws_lb.application.dns_name
  description = "The domain name of hte load balancer"
}

output "alb_http_listener_arn" {
  value       = aws_lb_listener.http.arn
  description = "The ARN of the HTTP listener"
}

output "security_group_id" {
  value       = aws_security_group.alb.id
  description = "The ALB Security Group ID"
}