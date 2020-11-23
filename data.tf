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