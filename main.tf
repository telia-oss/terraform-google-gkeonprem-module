resource "google_gkeonprem_vmware_cluster" "cluster" {
  name                     = var.cluster_name
  location                 = var.location
  admin_cluster_membership = var.admin_cluster_membership
  description              = var.cluster_name
  project                  = var.project_id
  on_prem_version          = var.gke_onprem_version
  annotations              = {}

  authorization {
    dynamic "admin_users" {
      for_each = var.admin_users
      content {
        username = admin_users.value
      }
    }
  }
  enable_control_plane_v2 = var.enable_control_plane_v2

  network_config {
    service_address_cidr_blocks = var.network_config.service_address_cidr_blocks
    pod_address_cidr_blocks     = var.network_config.pod_address_cidr_blocks

    host_config {
      dns_servers = var.network_config.dns_servers
      ntp_servers = var.network_config.ntp_servers
    }

    control_plane_v2_config {
      control_plane_ip_block {
        dynamic "ips" {
          for_each = var.network_config.control_plane_ips
          content {
            ip = ips.value
          }
        }
        netmask = var.network_config.netmask
        gateway = var.network_config.gateway
      }
    }

    static_ip_config {
      ip_blocks {
        netmask = var.network_config.netmask
        gateway = var.network_config.gateway

        dynamic "ips" {
          for_each = local.worker_ips
          content {
            ip = ips.value
          }
        }
      }
    }

    vcenter_network = var.network_config.vcenter_network
  }

  control_plane_node {
    cpus     = var.control_plane_node.cpus
    memory   = var.control_plane_node.memory
    replicas = var.control_plane_node.replicas
  }



  load_balancer {
    vip_config {
      control_plane_vip = var.load_balancer_config.control_plane_vip
      ingress_vip       = var.load_balancer_config.ingress_vip
    }
    metal_lb_config {
      dynamic "address_pools" {
        for_each = var.load_balancer_config.address_pools
        content {
          pool            = address_pools.key
          manual_assign   = address_pools.value.manual_assign
          addresses       = address_pools.value.addresses
          avoid_buggy_ips = address_pools.value.avoid_buggy_ips
        }
      }
    }
  }

  vcenter {
    resource_pool = var.vcenter_config.resource_pool
    folder        = var.vcenter_config.folder
  }

  auto_repair_config {
    enabled = true
  }

  anti_affinity_groups {
    aag_config_disabled = true
  }

  lifecycle {
    ignore_changes = [
      vcenter[0].ca_cert_data,
      vcenter[0].cluster,
      vcenter[0].datacenter,
      vcenter[0].datastore,
      dataplane_v2
    ]
  }
  timeouts {
    create = var.timeout_create
    update = var.timeout_update
    delete = var.timeout_delete
  }
}

resource "google_gkeonprem_vmware_node_pool" "node_pool" {
  for_each       = var.node_pools_config
  name           = each.key
  location       = var.location
  project        = var.project_id
  vmware_cluster = google_gkeonprem_vmware_cluster.cluster.name
  annotations    = {}

  config {
    cpus              = each.value.cpus
    memory_mb         = each.value.memory_mb
    replicas          = each.value.replicas
    image_type        = each.value.image_type
    boot_disk_size_gb = each.value.boot_disk_size_gb
    labels = {
      "cloud.google.com/gke-nodepool" = each.key
    }
    enable_load_balancer = true
  }

  node_pool_autoscaling {
    min_replicas = each.value.min_replicas
    max_replicas = each.value.max_replicas
  }

  lifecycle {
    ignore_changes = [
      config[0].vsphere_config,
      config[0].image_type,
      config[0].image
    ]
  }
  timeouts {
    create = var.timeout_create
    update = var.timeout_update
    delete = var.timeout_delete
  }
}