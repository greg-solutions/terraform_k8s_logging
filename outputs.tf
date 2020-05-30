output "namespace" {
  value = var.namespace
}
output "kibana_url" {
  value = "kibana.${var.domain}"
}