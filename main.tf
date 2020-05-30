# Namespace create
resource "kubernetes_namespace" "namespace" {
  count = var.create_namespace ? 1 : 0
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

# ElasticSearch
module "elasticsearch_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_deploy.git?ref=v1.0.2"

  name             = var.elasticsearch_name
  namespace        = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  image            = var.elasticsearch_docker_image
  internal_port    = var.elasticsearch_ports
  volume_mount     = var.elasticsearch_volume_mount
  env              = var.elasticsearch_env
  volume_nfs       = local.volume_nfs
  volume_aws_disk  = local.volume_aws_disk
  volume_gce_disk  = local.volume_gce_disk
  resources        = var.elasticsearch_resources
  security_context = var.elasticsearch_security_context
}
module "elasticsearch_service" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_service.git?ref=v1.0.0"

  app_name      = var.elasticsearch_name
  app_namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  port_mapping  = var.elasticsearch_ports
}

# Kibana
module "kibana_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_deploy.git?ref=v1.0.2"

  name            = var.kibana_name
  namespace       = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  image           = var.kibana_docker_image
  internal_port   = var.kibana_ports
  volume_mount    = var.kibana_volume_mount
  env             = var.kibana_env
  volume_nfs      = [
    {
      path_on_nfs  = var.path_on_nfs
      nfs_endpoint = var.nfs_endpoint
      volume_name  = "volume"
    }
  ]
  resources       = var.kibana_resources
}
module "kibana_service" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_service.git?ref=v1.0.0"

  app_name      = var.kibana_name
  app_namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  port_mapping  = var.kibana_ports
}
module "kibana_ingress" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_ingress.git?ref=v1.0.0"
  app_name = var.kibana_name
  app_namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  domain_name = var.domain
  web_internal_port = [
    {
      sub_domain = "kibana."
      internal_port = var.kibana_ports[0].internal_port
    }
  ]
  tls = var.tls
  annotations = var.ingress_annotations
}

# Filebeat

module "filebeat_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_daemonset.git?ref=v1.0.0"

  name                  = var.filebeat_name
  namespace             = var.namespace
  image                 = var.filebeat_docker_image
  volume_host_path      = var.filebeat_volume_node
  volume_config_map     = [
    {
      mode        = "0777"
      name        = kubernetes_config_map.filebeat_config.metadata[0].name
      volume_name = "filebeat"
    }
  ]
  env                   = var.filebeat_env
  env_field             = var.filebeat_env_field
  volume_mount          = var.filebeat_volume_mount
  security_context      = var.filebeat_security_context
  args                  = var.filebeat_args
  service_account_token = var.filebeat_rbac_enabled ? "true" : null
  service_account_name  = var.filebeat_rbac_enabled ? kubernetes_service_account.filebeat_service_account[0].metadata[0].name : null
  custom_labels         = merge(
  {
    app = var.filebeat_name
  },
  var.filebeat_labels)
}

resource "kubernetes_config_map" "filebeat_config" {
  metadata {
    name      = "filebeat-config"
    namespace = var.namespace
  }
  data = {
    "filebeat.yml" = var.filebeat_custom_config == null ? "${file("${path.module}/templates/filebeat.yml")}" : var.filebeat_custom_config
  }
}