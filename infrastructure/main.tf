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
  network = google_compute_network.west.name
  subnetwork = "regions/${var.region}/subnetworks/${google_compute_subnetwork.west.name}"
  name     = var.cluster_name
  project =  var.proj_name
  location = var.location
  cluster_ipv4_cidr = 10.132.0.0/14
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

resource "google_compute_address" "db_internal_ip" {
  name         = "db-internal-ip"
  subnetwork   = google_compute_subnetwork.west.id
  address_type = "INTERNAL"
  region  = var.region
  address      = "10.132.0.5"
  project = "${var.proj_name}"
}

output db_internal_ip {
  value       = google_compute_address.db_internal_ip.address
  description = "description"
}
output "cluster_ipv4_cidr" {
  value = google_container_cluster.primary.cluster_ipv4_cidr
}

resource "google_compute_network" "west" {
  project =  var.proj_name
  name = "gke-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "west" {
  project =  var.proj_name
  name          = "gke-subnetwork"
  ip_cidr_range = "10.132.0.0/20"
  region        = "europe-west1"
  network       = google_compute_network.west.id
}
