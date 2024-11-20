variable "cluster_name" {
  type        = string
  description = "Name of the GKE on-prem cluster"
}

variable "location" {
  type        = string
  description = "Location for the cluster"
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "admin_cluster_membership" {
  type        = string
  description = "Admin cluster membership path"
}

variable "admin_users" {
  type        = list(string)
  description = "List of users that should have cluster admin access through authorization block"
}

variable "network_config" {
  type = object({
    service_address_cidr_blocks = list(string)
    pod_address_cidr_blocks     = list(string)
    dns_servers                 = list(string)
    ntp_servers                 = list(string)
    vcenter_network            = string
    control_plane_ips          = list(string)
    worker_node_ips            = list(string)
    netmask                    = string
    gateway                    = string
  })
  description = "Network configuration for the cluster"
}

variable "vcenter_config" {
  type = object({
    resource_pool = string
    folder       = string
  })
  description = "vCenter configuration"
}

variable "control_plane_config" {
  type = object({
    cpus     = number
    memory   = number
    replicas = number
  })
  description = "Control plane node configuration"
}

variable "node_pools_config" {
  type = map(object({
    cpus              = number
    memory_mb         = number
    replicas          = number
    min_replicas      = number
    max_replicas      = number
    boot_disk_size_gb = number
    image_type        = string
  }))
  description = "Map of node pool configurations"
  default = {
    "default-pool" = {
      cpus              = 2
      memory_mb         = 4096
      replicas          = 3
      min_replicas      = 3
      max_replicas      = 4
      boot_disk_size_gb = 30
      image_type        = "cos_cgv2"
    }
  }
}

variable "load_balancer_config" {
  type = object({
    control_plane_vip = string
    ingress_vip       = string
    address_pool_range = string
  })
  description = "Load balancer configuration"
}

variable "connect_gateway_users" {
  type        = list(string)
  description = "List of users that should have GKE Connect Gateway access"
  default     = []
}

variable "image_type" {
  type        = string
  description = "Image type for the cluster"
  default     = "cos_cgv2" 
}

variable "gke_onprem_version" {
  type        = string
  description = "GKE on-prem version"
  default     = "1.30.0-gke.1930"
  
}

variable "enable_control_plane_v2" {
  type        = bool
  description = "Enable control plane v2"
  default     = true
}