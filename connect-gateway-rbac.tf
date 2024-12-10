locals {
  service_account = {
    name      = "connect-agent-sa"
    namespace = "gke-connect"
  }
}

resource "kubernetes_cluster_role" "gateway_impersonate" {
  count = length(var.connect_gateway_users) > 0 ? 1 : 0

  metadata {
    name = "gateway-impersonate"
  }
  rule {
    api_groups     = [""]
    resources      = ["users"]
    resource_names = var.connect_gateway_users
    verbs          = ["impersonate"]
  }
  depends_on = [module.cluster_credentials]
}

resource "kubernetes_cluster_role_binding" "gateway_impersonate" {
  count = length(var.connect_gateway_users) > 0 ? 1 : 0

  metadata {
    name = "gateway-impersonate"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.gateway_impersonate[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.service_account.name
    namespace = local.service_account.namespace
  }
  depends_on = [module.cluster_credentials]
}

resource "kubernetes_cluster_role_binding" "gateway_cluster_admin" {
  count = length(var.connect_gateway_users) > 0 ? 1 : 0

  metadata {
    name = "gateway-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  dynamic "subject" {
    for_each = var.connect_gateway_users
    content {
      kind = "User"
      name = subject.value
    }
  }
  depends_on = [module.cluster_credentials]
}