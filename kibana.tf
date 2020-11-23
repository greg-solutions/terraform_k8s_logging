# Kibana
module "kibana_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_deploy.git?ref=v1.0.8"

  name          = var.kibana_name
  namespace     = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  image         = var.kibana_docker_image
  internal_port = var.kibana_ports
  volume_mount  = var.kibana_volume_mount
  env           = var.kibana_env
  env_secret    = local.kibana_env_secret
  node_selector = var.kibana_node_selector
  volume_nfs = [
    {
      path_on_nfs  = var.path_on_nfs
      nfs_endpoint = var.nfs_endpoint
      volume_name  = "volume"
    }
  ]
  resources = var.kibana_resources
}

module "kibana_service" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_service.git?ref=v1.0.0"

  app_name      = var.kibana_name
  app_namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  port_mapping  = var.kibana_ports
}

module "kibana_ingress" {
  source        = "git::https://github.com/greg-solutions/terraform_k8s_ingress.git?ref=v1.0.2"
  app_name      = var.kibana_name
  app_namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  domain_name   = var.domain
  web_internal_port = [
    {
      sub_domain    = "kibana."
      internal_port = var.kibana_ports[0].internal_port
    }
  ]
  tls         = var.tls
  tls_hosts   = var.tls_hosts
  annotations = var.ingress_annotations
}