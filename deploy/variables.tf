variable app_label {
  type        = string
  default     = "group2-app"
  description = "description"
}

variable gke_cluster_remote_state {
  type        = "map"
  description = "GKE cluster remote state parameters"
}
