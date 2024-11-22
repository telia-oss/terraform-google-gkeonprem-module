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
    vcenter_network             = string
    control_plane_ips           = list(string)
    worker_node_ips             = list(string)
    netmask                     = string
    gateway                     = string
  })
  description = "Network configuration for the cluster"
}

variable "vcenter_config" {
  type = object({
    resource_pool = string
    folder        = string
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
    cpus              = optional(number, 2)
    memory_mb         = optional(number, 4096)
    replicas          = optional(number, 3)
    min_replicas      = optional(number, 3)
    max_replicas      = optional(number, 4)
    boot_disk_size_gb = optional(number, 30)
    image_type        = optional(string, "cos_cgv2")
  }))
  description = "Map of node pool configurations"
}

variable "load_balancer_config" {
  type = object({
    control_plane_vip  = string
    ingress_vip        = string
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

  validation {
    condition     = contains(["cos_cgv2", "cos", "ubuntu_cgv2", "ubuntu", "ubuntu_containerd", "windows"], var.image_type)
    error_message = "Allowed values for image_type are: cos, cos_cgv2, ubuntu, ubuntu_cgv2, ubuntu_containerd and windows"
  }
}



variable "gke_onprem_version" {
  type        = string
  description = "GKE on-prem version"
  default     = "1.30.0-gke.1930"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+-gke\\.[0-9]+$", var.gke_onprem_version))
    error_message = "GKE on-prem version must be in format X.Y.Z-gke.N"
  }
}

variable "enable_control_plane_v2" {
  type        = bool
  description = "Enable control plane v2"
  default     = true
}