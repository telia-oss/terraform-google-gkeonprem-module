module "cluster_credentials" {
  count                             = length(var.connect_gateway_users) > 0 ? 1 : 0
  source                            = "terraform-google-modules/gcloud/google"
  version                           = "~> 3.0"
  platform                          = var.platform
  additional_components             = ["kubectl", "gke-gcloud-auth-plugin", "beta"]
  create_cmd_body                   = "container hub memberships get-credentials ${google_gkeonprem_vmware_cluster.cluster.name} --project ${var.project_id} --quiet"
  create_cmd_triggers               = { connect_gateway_users_checksum = md5(join(",", var.connect_gateway_users)) }
  module_depends_on                 = [google_gkeonprem_vmware_cluster.cluster]
  use_tf_google_credentials_env_var = true
  activate_service_account          = true

}

