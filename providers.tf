terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
  }
  required_version = ">= 1.7.0"
}
