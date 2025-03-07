resource "helm_release" "connect_gateway_rbac" {
  count     = length(var.connect_gateway_users) > 0 ? 1 : 0
  name      = "connect-gateway-rbac"
  namespace = "gke-connect"
  chart     = "${path.module}/connect-gateway-rbac"
  wait      = true
  timeout   = 300
  set_list = [{
    name  = "connectGatewayUsers"
    value = var.connect_gateway_users
  }]
  depends_on = [google_gkeonprem_vmware_node_pool.node_pool]
}

