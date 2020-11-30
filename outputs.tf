output "namespace" {
  value = var.namespace
}
output "kibana_url" {
  value = "kibana.${var.domain}"
}
output "elasticsearch_lb_endpoint" {
  value = var.elasticsearch_service_type == "LoadBalancer" ? module.elasticsearch_service.load_balancer_ingress_hostname : null
}
output "elasticsearch_internal_endpoint" {
  value = "${var.elasticsearch_name}.${var.namespace}.svc.cluster.local"
}
output "elastic_username" {
  value = var.elasticsearch_username
}
output "elastic_password" {
  value = var.elasticsearch_password
}
output "kibana_admin_user_name" {
  value = var.kibana_admin_user_name
}
output "kibana_admin_user_pass" {
  value = random_password.kibana_admin_password.result
}
output "kibana_readonly_user_name" {
  value = var.kibana_readonly_user_name
}
output "kibana_readonly_user_pass" {
  value = random_password.kibana_readonly_password.result
}
output "kibana_users_provision_script" {
  value = data.template_file.kibana_user_provision_script.rendered
}