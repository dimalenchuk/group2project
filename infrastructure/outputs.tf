output "gke_endpoint" {
  value = google_container_cluster.primary.endpoint
  sensitive = true
}
output "access_token" {
  value = google_client_config.default.access_token
  sensitive = true
}
output "client_certificate" {
  value = google_container_cluster.primary.master_auth.0.client_certificate
  sensitive = true
}
output "client_key" {
  value = google_container_cluster.primary.master_auth.0.client_key
  sensitive = true
}
output "ca_certificate" {
  value = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  sensitive = true
}
