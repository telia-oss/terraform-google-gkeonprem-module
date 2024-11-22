# Google Cloud GKE On-Prem Terraform Module

This Terraform module deploys Google Kubernetes Engine (GKE) on-premises clusters on VMware infrastructure.

## Features

- Creates GKE on-prem clusters on VMware vSphere
- Supports multiple node pools with autoscaling
- Configurable control plane nodes
- Flexible networking options (static IP or DHCP)
- Load balancer integration (F5, MetalLB, Manual)
- RBAC and authentication management
- Control plane v2 support

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| google | >= 4.0 |
| kubernetes | >= 2.0 |

## Usage

Basic usage:

```hcl
module "gke_onprem" {
  source = "terraform-google-modules/gke-onprem/google"
  version = "~> 1.0"

  cluster_name             = "my-cluster"
  location                 = "us-west1"
  project_id              = "my-project"
  admin_cluster_membership = "projects/my-project/locations/us-west1/memberships/admin-cluster"
  
  network_config = {
    service_address_cidr_blocks = ["172.16.0.0/20"]
    pod_address_cidr_blocks     = ["192.168.0.0/16"]
    dns_servers                 = ["10.0.0.10"]
    ntp_servers                 = ["time.google.com"]
    vcenter_network            = "VM Network"
    control_plane_ips          = ["10.0.0.5", "10.0.0.6", "10.0.0.7"]
    worker_node_ips            = ["10.0.0.10", "10.0.0.11"]
    netmask                    = "255.255.255.0"
    gateway                    = "10.0.0.1"
  }

  vcenter_config = {
    resource_pool = "/Datacenter/host/Cluster/Resources/Pool"
    folder        = "/Datacenter/vm/Folder"
  }

  node_pools_config = {
    "pool-1" = {
      cpus              = 4
      memory_mb         = 16384
      replicas          = 3
      min_replicas      = 3
      max_replicas      = 5
      boot_disk_size_gb = 100
    }
  }
}
```

## Required Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| cluster_name | The name of the GKE on-prem cluster | `string` | n/a |
| location | The GCP location where the cluster will be created | `string` | n/a |
| project_id | The GCP project ID | `string` | n/a |
| admin_cluster_membership | The admin cluster membership path | `string` | n/a |
| network_config | Network configuration object containing CIDR blocks, IPs, and network settings | <pre>object({<br>  service_address_cidr_blocks = list(string)<br>  pod_address_cidr_blocks     = list(string)<br>  dns_servers                 = list(string)<br>  ntp_servers                 = list(string)<br>  vcenter_network            = string<br>  control_plane_ips          = list(string)<br>  worker_node_ips            = list(string)<br>  netmask                    = string<br>  gateway                    = string<br>})</pre> | n/a |
| vcenter_config | VMware vCenter configuration | <pre>object({<br>  resource_pool = string<br>  folder        = string<br>})</pre> | n/a |

## Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| gke_onprem_version | The version of GKE on-prem to install | `string` | `"1.30.0-gke.1930"` |
| enable_control_plane_v2 | Whether to enable control plane v2 | `bool` | `true` |
| image_type | The OS image type for nodes | `string` | `"cos_cgv2"` |
| admin_users | List of users to grant cluster admin access | `list(string)` | `[]` |
| connect_gateway_users | List of users to grant gateway access | `list(string)` | `[]` |
| node_pools_config | Map of node pool configurations | <pre>map(object({<br>  cpus              = optional(number, 2)<br>  memory_mb         = optional(number, 4096)<br>  replicas          = optional(number, 3)<br>  min_replicas      = optional(number, 3)<br>  max_replicas      = optional(number, 4)<br>  boot_disk_size_gb = optional(number, 30)<br>  image_type        = optional(string, "cos_cgv2")<br>}))</pre> | `{}` |
| load_balancer_config | Load balancer configuration | <pre>object({<br>  control_plane_vip  = string<br>  ingress_vip        = string<br>  address_pool_range = string<br>})</pre> | n/a |