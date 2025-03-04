resource "helm_release" "connect_gateway_rbac" {
  name      = "connect-gateway-rbac"
  namespace = "gke-connect"
  chart     = "./connect-gateway-rbac" # Path to your local chart directory
  wait      = true
  timeout   = 300
  values = [
    yamlencode({
      connectGatewayUsers = var.connect_gateway_users
    })
  ]
  depends_on = [google_gkeonprem_vmware_cluster.cluster]
}
