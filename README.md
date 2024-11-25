# Google Cloud GKE On-Premises VMware Terraform Module

This Terraform module deploys Google Kubernetes Engine (GKE) On-Premises clusters on VMware vSphere infrastructure, with support for multiple node pools, load balancing, and RBAC configuration.

## Features

- Creates and manages GKE on-prem clusters on VMware vSphere
- Configurable control plane with optional V2 features
- Supports multiple node pools with autoscaling capabilities
- Flexible IP management for worker nodes using IP ranges
- MetalLB integration for load balancing with customizable address pools
- RBAC configuration with admin and gateway user management 
- Anti-affinity group and auto-repair configuration
- IP range validation and automatic IP allocation from ranges

## Requirements

| Name       | Version   |
| ---------- | --------- |
| terraform  | >= 1.0    |
| google     | >= 6.12.0 |
| kubernetes | >= 2.33.0 |

## Usage

```hcl
module "gke_onprem_vmware_cluster" {
  source = "telia-oss/gkeonprem/gcp"

  # Required parameters
  cluster_name             = "my-cluster"
  location                 = "us-west1"
  project_id               = "my-project"
  admin_cluster_membership = "projects/my-project/locations/us-west1/memberships/admin-cluster"
  admin_users              = ["admin@example.com"]

  # vCenter configuration
  vcenter_config = {
    resource_pool = "/Datacenter/host/Cluster/Resources/Pool"
    folder        = "/Datacenter/vm/Folder"
  }

  # Network configuration
  network_config = {
    dns_servers           = ["8.8.8.8"]
    ntp_servers           = ["time.google.com"]
    vcenter_network       = "VM Network"
    control_plane_ips     = ["10.0.0.5", "10.0.0.6", "10.0.0.7"]
    worker_node_ip_ranges = ["10.0.0.20-10.0.0.30"]
    netmask               = "255.255.255.0"
    gateway               = "10.0.0.1"
  }

  # Load balancer configuration
  load_balancer_config = {
    control_plane_vip = "10.0.0.100"
    ingress_vip       = "10.0.0.101"
    address_pools = {
      "default-pool" = {
        addresses       = ["10.0.0.200-10.0.0.250"]
        manual_assign   = false
        avoid_buggy_ips = true
      }
    }
  }

  # Optional configurations
  control_plane_node = {
    cpus     = 4
    memory   = 8192
    replicas = 3
  }

  node_pools_config = {
    "default-pool" = {
      cpus              = 2
      memory_mb         = 4096
      replicas          = 3
      min_replicas      = 3
      max_replicas      = 4
      boot_disk_size_gb = 30
      image_type        = "cos_cgv2"
    }
    # Additional node pools can be defined here
  }

  connect_gateway_users   = ["user1@example.com", "user2@example.com"]
  gke_onprem_version      = "1.30.0-gke.1930"
  enable_control_plane_v2 = true
}
```

# GKE On-Prem Cluster Configuration

## Required Inputs

| Name                       | Description                                        | Type                                                                                                                                                                                                                                                                                                                                                                                                                                 | Default |
| -------------------------- | -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| `cluster_name`             | The name of the GKE on-prem cluster                | `string`                                                                                                                                                                                                                                                                                                                                                                                                                             | n/a     |
| `location`                 | The GCP location where the cluster will be created | `string`                                                                                                                                                                                                                                                                                                                                                                                                                             | n/a     |
| `project_id`               | The GCP project ID                                 | `string`                                                                                                                                                                                                                                                                                                                                                                                                                             | n/a     |
| `admin_cluster_membership` | The admin cluster membership path                  | `string`                                                                                                                                                                                                                                                                                                                                                                                                                             | n/a     |
| `admin_users`              | List of users for cluster admin access             | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                       | `[]`    |
| `network_config`           | Network configuration for the cluster              | <details><summary>object</summary><pre>{<br> service_address_cidr_blocks = optional(list(string), ["10.96.0.0/12"])<br> pod_address_cidr_blocks = optional(list(string), ["192.168.0.0/16"])<br> dns_servers = list(string)<br> ntp_servers = list(string)<br> vcenter_network = string<br> control_plane_ips = list(string)<br> worker_node_ip_ranges = list(string)<br> netmask = string<br> gateway = string<br>}</pre></details> | n/a     |
| `load_balancer_config`     | Load balancer configuration                        | <details><summary>object</summary><pre>{<br> control_plane_vip = string<br> ingress_vip = string<br> address_pools = map(object({<br> manual_assign = optional(bool, false)<br> addresses = list(string)<br> avoid_buggy_ips = optional(bool, true)<br>}))<br>}</pre></details>                                                                                                                                                      | n/a     |
| `vcenter_config`           | VMware vCenter configuration                       | <details><summary>object</summary><pre>{<br> resource_pool = string<br> folder = string<br>}</pre></details>                                                                                                                                                                                                                                                                                                                         | n/a     |

---

## Optional Inputs

| Name                      | Description                                  | Type                                                                                                                                                                                                                                                                                                                                                                                                       | Default                                                           |
| ------------------------- | -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `gke_onprem_version`      | The version of GKE on-prem to install        | `string`                                                                                                                                                                                                                                                                                                                                                                                                   | `"1.30.0-gke.1930"`                                               |
| `enable_control_plane_v2` | Whether to enable control plane v2           | `bool`                                                                                                                                                                                                                                                                                                                                                                                                     | `true`                                                            |
| `image_type`              | The OS image type for nodes                  | `string`                                                                                                                                                                                                                                                                                                                                                                                                   | `"cos_cgv2"`                                                      |
| `admin_users`             | List of users to grant cluster admin access  | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                             | `[]`                                                              |
| `connect_gateway_users`   | List of users for GKE Connect Gateway access | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                             | `[]`                                                              |
| `node_pools_config`       | Map of node pool configurations              | <details><summary>map(object)</summary><pre>{<br>  cpus              = optional(number, 2)<br>  memory_mb         = optional(number, 4096)<br>  replicas          = optional(number, 3)<br>  min_replicas      = optional(number, 3)<br>  max_replicas      = optional(number, 4)<br>  boot_disk_size_gb = optional(number, 30)<br>  image_type        = optional(string, "cos_cgv2")<br>}</pre></details> | `{}`                                                              |
| `control_plane_node`      | Control plane node configuration             | <details><summary>object</summary><pre>{<br> cpus = optional(number, 4)<br> memory = optional(number, 8192)<br> replicas = optional(number, 3)<br>}</pre></details>                                                                                                                                                                                                                                        | <pre>{<br> cpus = 4<br> memory = 8192<br> replicas = 3<br>}</pre> |

---

### Notes
- **Collapsible Details**: Inputs with complex types are wrapped in collapsible `<details>` blocks to reduce clutter while keeping the content easily accessible.
- **Ease of Maintenance**: By using collapsible details, you can expand only the necessary sections for edits, reducing the likelihood of formatting errors.

# Notes on Input Types

## `network_config`

- **`service_address_cidr_blocks`**:  
  Optional list of CIDR blocks for service addresses.  
  *Default*: `["10.96.0.0/12"]`.

- **`pod_address_cidr_blocks`**:  
  Optional list of CIDR blocks for pod addresses.  
  *Default*: `["192.168.0.0/16"]`.

- **`dns_servers`**:  
  List of DNS server IP addresses (*required*).

- **`ntp_servers`**:  
  List of NTP server IP addresses (*required*).

- **`vcenter_network`**:  
  The VMware vCenter network name (*required*).

- **`control_plane_ips`**:  
  List of static IPs for control plane nodes (*required*).

- **`worker_node_ip_ranges`**:  
  List of IP ranges for worker nodes in the format `"x.x.x.y-x.x.x.z"` (*required*).

- **`netmask`**:  
  Netmask for the network (*required*).

- **`gateway`**:  
  Gateway IP address for the network (*required*).

---

## `vcenter_config`

- **`resource_pool`**:  
  Full path to the vCenter resource pool (*required*).

- **`folder`**:  
  Full path to the vCenter folder (*required*).

---

## `load_balancer_config`

- **`control_plane_vip`**:  
  Virtual IP for the control plane (*required*).

- **`ingress_vip`**:  
  Virtual IP for ingress (*required*).

- **`address_pools`**:  
  Map of address pool configurations (*required*). Each pool includes:
  - **`manual_assign`**:  
    Optional boolean to manually assign IPs.  
    *Default*: `false`.
  - **`addresses`**:  
    List of IP addresses or ranges (*required*).
  - **`avoid_buggy_ips`**:  
    Optional boolean to avoid buggy IPs.  
    *Default*: `true`.

---

## `control_plane_node`

- **`cpus`**:  
  Number of CPUs for control plane nodes.  
  *Optional, Default*: `4`.

- **`memory`**:  
  Memory in MB for control plane nodes.  
  *Optional, Default*: `8192`.

- **`replicas`**:  
  Number of control plane node replicas.  
  *Optional, Default*: `3`.

---

## `node_pools_config`

Map where each key is a node pool name and the value is an object containing:

- **`cpus`**:  
  Number of CPUs.  
  *Optional, Default*: `2`.

- **`memory_mb`**:  
  Memory in MB.  
  *Optional, Default*: `4096`.

- **`replicas`**:  
  Number of replicas.  
  *Optional, Default*: `1`.

- **`min_replicas`**:  
  Minimum number of replicas for autoscaling.  
  *Optional, Default*: `1`.

- **`max_replicas`**:  
  Maximum number of replicas for autoscaling.  
  *Optional, Default*: `3`.

- **`boot_disk_size_gb`**:  
  Boot disk size in GB.  
  *Optional, Default*: `30`.

- **`image_type`**:  
  OS image type for nodes.  
  *Optional, Default*: `"cos_cgv2"`.  
  *Allowed values*: `"cos_cgv2"`, `"cos"`, `"ubuntu_cgv2"`, `"ubuntu"`, `"ubuntu_containerd"`, `"windows"`.