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
    service_address_cidr_blocks = optional(list(string), ["10.96.0.0/12"])
    pod_address_cidr_blocks     = optional(list(string), ["192.168.0.0/16"])
    dns_servers                 = list(string)
    ntp_servers                 = list(string)
    vcenter_network             = string
    control_plane_ips           = list(string)
    worker_node_ip_ranges       = list(string)
    netmask                     = string
    gateway                     = string
  })
  description = "Network configuration for the cluster"

  validation {
    condition = alltrue([
      for range in var.network_config.worker_node_ip_ranges :
      can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\-((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", range))
      &&
      join("", split(".", element(split("-", range), 0))) < join("", split(".", element(split("-", range), 1)))
    ])
    error_message = "Worker node IP ranges must be in format: x.x.x.y-x.x.x.z where x,y,z are valid IPv4 octets (0-255) and z > y"
  }

  validation {
    condition = alltrue([
      for range in var.network_config.worker_node_ip_ranges :
      tonumber(split(".", split("-", range)[1])[3]) > tonumber(split(".", split("-", range)[0])[3])
    ])
    error_message = "End IP must be greater than start IP in each range"
  }
}

variable "vcenter_config" {
  type = object({
    resource_pool = string
    folder        = string
  })
  description = "vCenter configuration"
}

variable "control_plane_node" {
  type = object({
    cpus     = optional(number, 4)
    memory   = optional(number, 8192)
    replicas = optional(number, 3)
  }) # Add empty map as default
  description = "Control plane node configuration"
  default = {
    cpus     = 4
    memory   = 8192
    replicas = 3
  }
}

variable "node_pools_config" {
  type = map(object({
    cpus              = optional(number, 2)
    memory_mb         = optional(number, 4096)
    replicas          = optional(number, 1)
    min_replicas      = optional(number, 1)
    max_replicas      = optional(number, 3)
    boot_disk_size_gb = optional(number, 30)
    image_type        = optional(string, "cos_cgv2")
  }))
  description = "Map of node pool configurations"

  validation {
    condition = alltrue([
      for k, v in var.node_pools_config : contains(
        ["cos_cgv2", "cos", "ubuntu_cgv2", "ubuntu", "ubuntu_containerd", "windows"],
        v.image_type
      )
    ])
    error_message = "Allowed values for image_type are: cos, cos_cgv2, ubuntu, ubuntu_cgv2, ubuntu_containerd and windows"
  }
}

variable "load_balancer_config" {
  type = object({
    control_plane_vip = string
    ingress_vip       = string
    address_pools = map(object({
      manual_assign   = optional(bool, false)
      addresses       = list(string)
      avoid_buggy_ips = optional(bool, true)
    }))
  })
  description = "Load balancer configuration"
}

variable "connect_gateway_users" {
  type        = list(string)
  description = "List of users that should have GKE Connect Gateway access"
  default     = []
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

variable "platform" {
  type        = string
  description = "Platform for the gcloud CLI module"
  default     = "linux"

  validation {
    condition     = can(regex("^(linux|darwin)$", var.platform))
    error_message = "Platform must be one of linux, darwin (macOS)"
  }
}

variable "timeout_create" {
  type        = string
  description = "Timeout for create operations"
  default     = "2h"
}

variable "timeout_update" {
  type        = string
  description = "Timeout for update operations"
  default     = "4h"
}

variable "timeout_delete" {
  type        = string
  description = "Timeout for delete operations"
  default     = "2h"
}