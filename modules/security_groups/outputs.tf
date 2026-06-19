output "ingress_alb_sg_id" {
  description = "ID of the security group to attach to the Ingress-managed ALB. Use this value in the Kubernetes Ingress annotation: alb.ingress.kubernetes.io/security-groups"
  value       = aws_security_group.ingress_alb_sg.id
}

output "ingress_alb_sg_arn" {
  description = "ARN of the security group for the Ingress-managed ALB"
  value       = aws_security_group.ingress_alb_sg.arn
}
