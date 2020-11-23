# ElasticSearch
module "elasticsearch_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_statefulset.git?ref=v1.1.5"

  name             = var.elasticsearch_name
  namespace        = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  image            = var.elasticsearch_docker_image
  internal_port    = var.elasticsearch_ports
  volume_mount     = var.elasticsearch_volume_mount
  env              = var.elasticsearch_env
  env_secret       = local.elastic_env_secret
  volume_nfs       = local.volume_nfs
  volume_aws_disk  = local.volume_aws_disk
  volume_gce_disk  = local.volume_gce_disk
  resources        = var.elasticsearch_resources
  security_context = var.elasticsearch_security_context
  node_selector    = var.elasticsearch_node_selector

  volume_config_map = [
    {
      mode        = "0777"
      name        = kubernetes_config_map.elastic_config.metadata[0].name
      volume_name = "elasticsearch-config"
    }
  ]
}
module "elasticsearch_service" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_service.git?ref=v1.0.0"

  app_name      = var.elasticsearch_name
  app_namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  port_mapping  = var.elasticsearch_ports
  type          = var.elasticsearch_service_type
  annotations   = var.elasticsearch_service_annotation
}