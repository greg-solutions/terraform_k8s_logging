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

# Filebeat
module "filebeat_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_daemonset.git?ref=v1.1.1"

  name             = var.filebeat_name
  namespace        = var.namespace
  image            = var.filebeat_docker_image
  volume_host_path = var.filebeat_volume_node
  volume_config_map = [
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
  custom_labels = merge(
    {
      app = var.filebeat_name
    },
  var.filebeat_labels)
}

resource "kubernetes_config_map" "filebeat_config" {
  metadata {
    name      = "filebeat-config"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
  data = {
    "filebeat.yml"             = var.filebeat_custom_config == null ? data.template_file.filebeat_config.rendered : var.filebeat_custom_config,
    "filebeat_ilm_policy.json" = var.filebeat_custom_ilm_policy == null ? data.template_file.filebeat_ilm_policy.rendered : var.filebeat_custom_ilm_policy
  }
}

data "template_file" "filebeat_config" {
  template = file("${path.module}/templates/filebeat.yml")

  vars = {
    ELASTICSEARCH_USERNAME = var.elasticsearch_username,
    ELASTICSEARCH_PASSWORD = var.elasticsearch_password,
    ELASTIC_INDEX_PREFIX   = var.elasticsearch_index_prefix,
    ELASTIC_HOST_NAME      = var.elasticsearch_name,
    ELASTIC_PORT           = lookup(var.elasticsearch_ports[0], "external_port")
  }
}

data "template_file" "filebeat_ilm_policy" {
  template = file("${path.module}/templates/filebeat_ilm_policy.json")

  vars = {
    HOT_PHASE_ENABLED    = var.filebeat_ilm_settings.hot_phase.enabled
    HOT_PHASE_MIN_AGE    = var.filebeat_ilm_settings.hot_phase.min_age,
    HOT_PHASE_MAX_AGE    = var.filebeat_ilm_settings.hot_phase.rollover_max_age,
    HOT_PHASE_MAX_SIZE   = var.filebeat_ilm_settings.hot_phase.rollover_max_size,
    WARM_PHASE_ENABLED   = var.filebeat_ilm_settings.warm_phase.enabled,
    WARM_PHASE_MIN_AGE   = var.filebeat_ilm_settings.warm_phase.min_age,
    COLD_PHASE_ENABLED   = var.filebeat_ilm_settings.cold_phase.enabled,
    COLD_PHASE_MIN_AGE   = var.filebeat_ilm_settings.cold_phase.min_age,
    DELETE_PHASE_ENABLED = var.filebeat_ilm_settings.delete_phase.enabled,
    DELETE_PHASE_MIN_AGE = var.filebeat_ilm_settings.delete_phase.min_age,
  }
}

resource "kubernetes_config_map" "elastic_config" {
  metadata {
    name      = "elasticsearch-config"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
  data = {
    "elasticsearch.yml" = var.elasticsearch_custom_config == null ? file("${path.module}/templates/elasticsearch.yml") : var.elasticsearch_custom_config
  }
}

data "template_file" "kibana_user_provision_script" {
  template = file("${path.module}/templates/users_provisioning_script_template.sh")

  vars = {
    ELASTIC_USERNAME          = var.elasticsearch_username,
    ELASTIC_PASSWORD          = var.elasticsearch_password,
    ENV_INDEX_PREFIX          = var.elasticsearch_index_prefix,
    KIBANA_READONLY_USER_NAME = var.kibana_readonly_user_name
    KIBANA_READONLY_USER_PASS = random_password.kibana_readonly_password.result,
    KIBANA_ADMIN_USER_NAME    = var.kibana_admin_user_name
    KIBANA_ADMIN_USER_PASS    = random_password.kibana_admin_password.result,
    ELASTIC_HOST_NAME         = var.elasticsearch_name,
    ELASTIC_PORT              = lookup(var.elasticsearch_ports[0], "external_port")
  }
}

# kibana readonly user password
resource "random_password" "kibana_readonly_password" {
  length           = 16
}

# kibana admin user password
resource "random_password" "kibana_admin_password" {
  length           = 16
}

resource "kubernetes_secret" "elastic_secrets" {
  metadata {
    name      = "elastic-secrets"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
  data = {
    elastic_password = var.elasticsearch_password
  }
  type = "Opaque"
}

resource "kubernetes_secret" "kibana_secrets" {
  metadata {
    name      = "kibana-secrets"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
  data = {
    elastic_username = var.elasticsearch_username
    elastic_password = var.elasticsearch_password
  }
  type = "Opaque"
}