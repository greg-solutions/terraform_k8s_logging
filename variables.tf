# Namespace
variable "namespace" {
  description = "Namespace name"
  type        = string
  default     = "logging"
}
variable "create_namespace" {
  description = "Create namespace by module ? true or false"
  type        = bool
  default     = true
}

# Volumes
variable "cloud_type_disk" {
  description = "Type of disk for elasticsearch: aws, gcp, nfs"
  type        = string
}
variable "path_on_nfs" {
  description = "Path on nfs if you use nfs"
  type        = string
  default     = "/"
}
variable "nfs_endpoint" {
  description = "Nfs endpoint if you use nfs and for kibana"
  type        = string
}
variable "gcp_disk_name" {
  description = "GCP disk name  for elasticsearch if you use GCP disk"
  type        = string
  default     = ""
}
variable "aws_volume_id" {
  description = "AWS ebs volume_id for elasticsearch if you use AWS disk"
  default     = ""
}

# URLs
variable "domain" {
  description = "Domain for kibana url, will create kibana.$domain"
  type        = string
}
variable "tls" {
  description = "TLS for kibana url"
  type        = list(string)
  default     = []
}
variable "tls_hosts" {
  description = "TLS for kibana url with host"
  default     = []
}
variable "ingress_annotations" {
  description = "Additional ingress annotations for kibana"
  default     = null
}

# Kibana
variable "kibana_readonly_user_name" {
  description = "Username for readonly user"
  default     = "readonly"
  type        = string
}
variable "kibana_admin_user_name" {
  description = "Username for admin user"
  default     = "admin"
  type        = string
}
variable "kibana_name" {
  description = "Name for resources"
  type        = string
  default     = "kibana"
}
variable "kibana_ports" {
  description = "Opened ports"
  default = [
    {
      name          = "web"
      internal_port = "5601"
      external_port = "5601"
    }
  ]
}
variable "kibana_resources" {
  description = "Resources limit/requests"
  default = [
    {
      request_cpu    = "100m"
      request_memory = "650Mi"
      limit_cpu      = "1000m"
      limit_memory   = "1200Mi"
    }
  ]
}
variable "kibana_docker_image" {
  description = "Docker image. Not recommend to change"
  # ilm delete phase doesn't work in newest version 7.10.0
  default = "elastic/kibana:7.9.3"
}
variable "kibana_volume_mount" {
  description = "Volume to mount"
  default = [
    {
      mount_path  = "/usr/share/kibana/data"
      sub_path    = "kibana-data"
      volume_name = "volume"
    }
  ]
}
variable "kibana_env" {
  description = "Environment variables"
  default     = []
}
variable "kibana_node_selector" {
  description = "Define Node where kibana must working"
  default     = null
  type        = map(string)
}

# ElasticSearch
variable "elasticsearch_name" {
  description = "Name for resources"
  type        = string
  default     = "elasticsearch"
}
variable "elasticsearch_ports" {
  description = "Opened ports"
  default = [
    {
      name          = "rest"
      internal_port = "9200"
      external_port = "9200"
    },
    {
      name          = "nodes"
      internal_port = "9300"
      external_port = "9300"
    }
  ]
}
variable "elasticsearch_resources" {
  description = "Resources limit/requests"
  default = [
    {
      request_cpu    = "100m"
      request_memory = "750Mi"
      limit_cpu      = "1000m"
      limit_memory   = "1200Mi"
    }
  ]
}
variable "elasticsearch_node_selector" {
  description = "Define Node where elastic must working"
  default     = null
  type        = map(string)
}
variable "elasticsearch_docker_image" {
  description = "Docker image. Not recommend to change"
  # ilm delete phase doesn't work in newest version 7.10.0
  default = "elastic/elasticsearch:7.9.3"
}
variable "elasticsearch_volume_mount" {
  description = "Volume to mount"
  default = [
    {
      mount_path  = "/usr/share/elasticsearch/data"
      sub_path    = "elasticsearch-data"
      volume_name = "volume"
    },
    {
      mount_path  = "/usr/share/elasticsearch/config/elasticsearch.yml"
      sub_path    = "elasticsearch.yml"
      volume_name = "elasticsearch-config"
    }
  ]
}
variable "elasticsearch_env" {
  description = "Environment variables"
  default = [
    {
      name  = "discovery.type"
      value = "single-node"
    },
    {
      name  = "ES_JAVA_OPTS"
      value = "-Xms256m -Xmx512m"
    },
    {
      name  = "bootstrap.memory_lock"
      value = "true"
    }
  ]
}
variable "elasticsearch_security_context" {
  description = "Security groups for volume"
  default = [
    {
      fs_group = "0"
    }
  ]
}
variable "elasticsearch_custom_config" {
  description = "Custom config elasticsearch.yml"
  default     = null
}
variable "elasticsearch_service_type" {
  description = "Elasticsearch service type"
  default     = "ClusterIP"
}
variable "elasticsearch_service_annotation" {
  description = "Annotation for elasticsearch service (if used type 'LoadBalancer')"
  default     = null
}

# Filebeat
variable "filebeat_name" {
  description = "Name for resources"
  default     = "filebeat-pods"
}
variable "elasticsearch_index_prefix" {
  description = "Elasticsearch index prefix for filebeat indices (sandbox, prod, staging, etc.)"
  type        = string
}
variable "filebeat_docker_image" {
  description = "Docker image. Not recommend to change"
  type        = string
  # ilm delete phase doesn't work in newest version 7.10.0
  default = "elastic/filebeat:7.9.3"
}
variable "elasticsearch_password" {
  description = "Elasticsearch superuser password"
  type        = string
}
variable "elasticsearch_username" {
  description = "Elasticsearch superuser username"
  type        = string
}
variable "filebeat_env" {
  description = "Environment variables"
  default = [
    {
      name  = "output.elasticsearch.hosts"
      value = "elasticsearch:9200"
    },
    {
      name  = "setup.kibana.host"
      value = "kibana:5601"
    }
  ]
}
variable "filebeat_env_field" {
  description = "Environment variables from field"
  default = [
    {
      name       = "NODE_NAME"
      field_path = "spec.nodeName"
    }
  ]
}
variable "filebeat_volume_mount" {
  description = "Volume to mount"
  default = [
    {
      mount_path  = "/var/lib/docker/containers"
      volume_name = "containers-log-node"
    },
    {
      mount_path  = "/var/run/docker.sock"
      volume_name = "docker-sock-node"
    },
    {
      mount_path  = "/usr/share/filebeat/filebeat.yml"
      sub_path    = "filebeat.yml"
      volume_name = "filebeat"
    },
    {
      mount_path  = "/usr/share/filebeat/filebeat_ilm_policy.json"
      sub_path    = "filebeat_ilm_policy.json"
      volume_name = "filebeat"
    }
  ]
}
variable "filebeat_volume_node" {
  description = "Volume from node where pod is running"
  default = [
    {
      path_on_node = "/var/lib/docker/containers"
      volume_name  = "containers-log-node"
    },
    {
      path_on_node = "/var/run/docker.sock"
      volume_name  = "docker-sock-node"
    },
  ]
}
variable "filebeat_security_context" {
  description = "Security context for start with custom config"
  default = [
    {
      user_id = "0"
    }
  ]
}
variable "filebeat_args" {
  description = "Args for start with custom config"
  default = [
    "filebeat",
    "-e",
    "-strict.perms=false"
  ]
}
variable "filebeat_labels" {
  description = "Additional labels for filebeat"
  default = {
    filebeat_logs = "false"
  }
}
variable "filebeat_custom_config" {
  description = "Custom config filebeat.yml"
  default     = null
}
variable "filebeat_custom_ilm_policy" {
  description = "Custom config for custom ilm policy"
  default     = null
}
variable "filebeat_ilm_custom_policy_config" {
  description = "Custom config filebeat index lifecycle management policy"
  default     = null
}
variable "filebeat_rbac_enabled" {
  description = "Create rbac rule for filebeat pods"
  type        = bool
  default     = true
}
variable "filebeat_ilm_settings" {
  description = "Elasticsearch ILM settings for filebeat index. See details on the elastic site: https://www.elastic.co/guide/en/elasticsearch/reference/7.9/ilm-actions.html"
  type = object({
    hot_phase = object({
      enabled           = bool,
      min_age           = string,
      rollover_max_size = string,
      rollover_max_age  = string
    }),
    warm_phase = object({
      enabled = bool,
      min_age = string
    }),
    cold_phase = object({
      enabled = bool,
      min_age = string
    }),
    delete_phase = object({
      enabled = bool,
      min_age = string
    })
  })

  default = {
    hot_phase = {
      enabled           = true,
      min_age           = "0ms",
      rollover_max_size = "2gb",
      rollover_max_age  = "7d"
    }
    warm_phase = {
      enabled = true,
      min_age = "10m",
    },
    cold_phase = {
      enabled = true,
      min_age = "10d",
    },
    delete_phase = {
      enabled = true,
      min_age = "60d",
    }
  }
}