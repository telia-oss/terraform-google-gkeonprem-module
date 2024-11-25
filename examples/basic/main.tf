module "gke_onprem_vmware_cluster" {
  source = "../../"

  # Required parameters
  cluster_name             = "example-cluster"
  location                 = "us-west1"
  admin_cluster_membership = "projects/example-project/locations/us-west1/memberships/example-admin-cluster"
  project_id               = "example-project"
  admin_users              = ["admin@example.com"]
  # Required vCenter configuration
  vcenter_config = {
    resource_pool = "/datacenter/cluster/resource_pool"
    folder        = "/datacenter/vm/folder"
  }
  # Basic network configuration
  network_config = {
    dns_servers           = ["8.8.8.8"]
    ntp_servers           = ["time.google.com"]
    vcenter_network       = "example-network"
    control_plane_ips     = ["192.168.1.1", "192.168.1.2", "192.168.1.3"]
    worker_node_ip_ranges = ["192.168.1.10-192.168.1.20"]
    netmask               = "255.255.255.0"
    gateway               = "192.168.1.254"
  }
  # Optional configurations with minimal overrides
  node_pools_config = {
    #"default-pool" = {}
  }
  # MetalLB configuration
  load_balancer_config = {
    control_plane_vip = "192.168.1.100"
    ingress_vip       = "192.168.1.101"
    address_pools = {
      "default-pool" = {
        addresses = ["192.168.1.101-192.168.1.120"]
      }
    }
  }
}

