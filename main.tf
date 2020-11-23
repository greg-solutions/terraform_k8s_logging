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

# Configmap with filebeat configs
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

# Configmap with elasticsearch configs
resource "kubernetes_config_map" "elastic_config" {
  metadata {
    name      = "elasticsearch-config"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
  data = {
    "elasticsearch.yml" = var.elasticsearch_custom_config == null ? file("${path.module}/templates/elasticsearch.yml") : var.elasticsearch_custom_config
  }
}

# kibana readonly user password
resource "random_password" "kibana_readonly_password" {
  length  = 16
  special = false
}

# kibana admin user password
resource "random_password" "kibana_admin_password" {
  length  = 16
  special = false
}

# elasticsearch password secret
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

# kibana password secret
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