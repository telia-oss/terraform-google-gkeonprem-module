
module "vmware_cluster" {
  source = "../../"

  cluster_name              = "example-cluster"
  location                  = "us-west1"
  admin_cluster_membership  = "projects/example-project/locations/us-west1/memberships/example-admin-cluster"
  project_id                = "example-project"
  gke_onprem_version        = "1.15.0"
  admin_users               = ["admin@example.com"]
  enable_control_plane_v2   = true
  connect_gateway_users     = ["user1@example.com", "user2@example.com"]

  network_config = {
    service_address_cidr_blocks = ["10.96.0.0/12"]
    pod_address_cidr_blocks     = ["192.168.0.0/16"]
    dns_servers                 = ["8.8.8.8"]
    ntp_servers                 = ["time.google.com"]
    control_plane_ips           = ["192.168.1.1"]
    worker_node_ips             = ["192.168.1.2", "192.168.1.3"]
    netmask                     = "255.255.255.0"
    gateway                     = "192.168.1.254"
    vcenter_network             = "example-network"
  }

  control_plane_config = {
    cpus     = 4
    memory   = 8192
    replicas = 1
  }

  load_balancer_config = {
    control_plane_vip = "192.168.1.100"
    ingress_vip       = "192.168.1.101"
    address_pool_range = "192.168.1.200-192.168.1.250"
  }

  vcenter_config = {
    resource_pool = "/datacenter/cluster/resource_pool"
    folder        = "/datacenter/vm/folder"
  }

  node_pools_config = {
    dev = {
      cpus              = 4
      memory_mb         = 8192
      replicas          = 3
      image_type        = "COS"
      boot_disk_size_gb = 100
      min_replicas      = 1
      max_replicas      = 5
    }
    prod = {
      cpus              = 8
      memory_mb         = 16384
      replicas          = 5
      image_type        = "COS"
      boot_disk_size_gb = 200
      min_replicas      = 3
      max_replicas      = 10
    }
  }
}
