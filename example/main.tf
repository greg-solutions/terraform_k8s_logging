module "logging" {
  source = "./"
  cloud_type_disk = "aws"
  aws_volume_id = "volume-id1231312"
  domain = "example.com"
  tls = ["tls-secret"]
  nfs_endpoint = "10.10.10.10"
}