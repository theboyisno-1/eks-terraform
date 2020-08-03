output "application_endpoint_hostname" {
  value = kubernetes_service.service.load_balancer_ingress.0.hostname
}

output "application_endpoint_ip" {
  value = kubernetes_service.service.load_balancer_ingress.0.ip
}