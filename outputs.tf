output "namespace" {
  value = var.namespace
}
output "kibana_url" {
  value = "kibana.${var.domain}"
}
output "elasticserach_url" {
  value = var.elasticsearch_service_type == "LoadBalancer" ? module.elasticsearch_service.load_balancer_ingress_hostname : null
}