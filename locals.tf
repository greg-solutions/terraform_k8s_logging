locals {
  volume_nfs = var.cloud_type_disk == "nfs" ? [
    {
      path_on_nfs  = var.path_on_nfs
      nfs_endpoint = var.nfs_endpoint
      volume_name  = "volume"
    }
  ] : []
  volume_gce_disk = var.cloud_type_disk == "gcp" ? [
    {
      gce_disk    = var.gcp_disk_name
      volume_name = "volume"
    }
  ] : []
  volume_aws_disk = var.cloud_type_disk == "aws" ? [
    {
      volume_id   = var.aws_volume_id
      volume_name = "volume"
    }
  ] : []

  elastic_env_secret = [
    {
      name        = "ELASTIC_PASSWORD"
      secret_name = kubernetes_secret.elastic_secrets.metadata[0].name
      secret_key  = "elastic_password"
  }]

  kibana_env_secret = [
    {
      name        = "ELASTICSEARCH_USERNAME"
      secret_name = kubernetes_secret.kibana_secrets.metadata[0].name
      secret_key  = "elastic_username"
    },
    {
      name        = "ELASTICSEARCH_PASSWORD"
      secret_name = kubernetes_secret.kibana_secrets.metadata[0].name
      secret_key  = "elastic_password"
    },
  ]
}