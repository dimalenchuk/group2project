provider "google" {
  user_project_override = true
}
terraform {
  backend "gcs" {
    bucket      = "tfstat"
    prefix      = "terraform/infrastructure"
  }
}

data "google_client_config" "default" {}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  project =  var.proj_name
  location = var.location
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  project =  var.proj_name
  name       = var.pool_name
  location   = var.location
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    machine_type = "e2-medium"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_compute_address" "load_balancer_ip" {
  name    = "load-balancer-ip"
  region  = var.region
  project = "${var.proj_name}"
}

