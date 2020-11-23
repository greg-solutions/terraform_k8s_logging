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