resource "kubernetes_service_account" "filebeat_service_account" {
  count = var.filebeat_rbac_enabled ? 1 : 0

  metadata {
    name      = var.filebeat_name
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "filebeat_role" {
  count = var.filebeat_rbac_enabled ? 1 : 0

  metadata {
    name       = var.filebeat_name
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "watch", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "watch", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "filebeat_role_binding" {
  count = var.filebeat_rbac_enabled ? 1 : 0

  metadata {
    name      = "${var.filebeat_name}-viewer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.filebeat_name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.filebeat_service_account[0].metadata[0].name
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
}