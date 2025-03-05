data "google_client_config" "provider" {
}

data "google_project" "project" {
  project_id = var.project_id
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.12"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
  }
  required_version = ">= 1.7.0"
}

provider "helm" {
  kubernetes {
    host  = local.connect_gateway_endpoint
    token = data.google_client_config.provider.access_token
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
  }
}

