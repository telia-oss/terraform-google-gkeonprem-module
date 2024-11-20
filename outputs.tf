output "cluster_name" {
  value       = google_gkeonprem_vmware_cluster.cluster.name
  description = "Name of the created GKE on-prem cluster"
}

output "cluster_id" {
  value       = google_gkeonprem_vmware_cluster.cluster.id
  description = "ID of the created GKE on-prem cluster"
}

output "node_pool_name" {
  value       = google_gkeonprem_vmware_node_pool.node_pool.name
  description = "Name of the created node pool"
}