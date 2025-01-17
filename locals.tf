locals {
  # Function to generate IP list from range
  worker_ips = flatten([
    for range in var.network_config.worker_node_ip_ranges : [
      for ip in range(
        tonumber(split(".", split("-", range)[0])[3]),
        tonumber(split(".", split("-", range)[1])[3]) + 1
        ) : format("%s.%s.%s.%d",
        split(".", split("-", range)[0])[0],
        split(".", split("-", range)[0])[1],
        split(".", split("-", range)[0])[2],
        ip
      )
    ]
  ])
  connect_gateway_endpoint = "https://${var.location}-connectgateway.googleapis.com/v1/projects/${data.google_project.project.number}/locations/${var.location}/memberships/${google_gkeonprem_vmware_cluster.cluster.name}"
}
