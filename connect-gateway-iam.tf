resource "google_project_iam_member" "connect_gateway_admin" {
  for_each = toset(local.connect_gateway_identities)
  project  = var.project_id
  role     = "roles/gkehub.gatewayAdmin"
  member   = each.value
}

resource "google_project_iam_member" "fleet_viewer" {
  for_each = toset(local.connect_gateway_identities)
  project  = var.project_id
  role     = "roles/gkehub.viewer"
  member   = each.value
}

resource "google_project_iam_member" "kubernetes_engine_cluster_viewer" {
  for_each = toset(local.connect_gateway_identities)
  project  = var.project_id
  role     = "roles/container.clusterViewer"
  member   = each.value
}