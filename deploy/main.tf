data "terraform_remote_state" "gke_cluster" {
  backend = "gcs"
  config = {
    bucket      = "tfstat"
    prefix      = "terraform/infrastructure"
  }
}
terraform {
  backend "gcs" {
    bucket      = "tfstat"
    prefix      = "terraform/deploy"
  }
}

provider "kubernetes" {
  load_config_file = false
  host     = data.terraform_remote_state.gke_cluster.outputs.gke_endpoint
  token = data.terraform_remote_state.gke_cluster.outputs.access_token

  client_certificate     = "${base64decode(data.terraform_remote_state.gke_cluster.outputs.client_certificate)}"
  client_key             = "${base64decode(data.terraform_remote_state.gke_cluster.outputs.client_key)}"
  cluster_ca_certificate = "${base64decode(data.terraform_remote_state.gke_cluster.outputs.ca_certificate)}"
}

resource "kubernetes_deployment" "mysql_deploy" {
  metadata {
    name = "mysql-deploy"

    labels = {
      app = var.app_label

      name = "mysql-deploy"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_label

        name = "mysql-pod"
      }
    }

    template {
      metadata {
        name = "mysql-pod"

        labels = {
          app = var.app_label

          name = "mysql-pod"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "dimalenchuk/novinanodb:2"

          port {
            container_port = 3306
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql_service" {
  metadata {
    name = "mysql-service"

    labels = {
      app = var.app_label

      name = "mysql-service"
    }
  }

  spec {
    cluster_ip = "10.3.240.111"
    port {
      port        = 3306
      target_port = "3306"
    }

    selector = {
      app = var.app_label

      name = "mysql-pod"
    }
  }
}

resource "kubernetes_deployment" "wordpress_deploy" {
  depends_on = ["kubernetes_service.mysql_service", "kubernetes_deployment.mysql_deploy"]
  metadata {
    name = "wordpress-deploy"

    labels = {
      app = var.app_label

      name = "wordpress-deploy"
    }
  }

  spec {
    replicas = 2
    
    selector {
      match_labels = {
        app = var.app_label

        name = "wordpress-pod"
      }
    }

    template {
      metadata {
        name = "wordpress-pod"

        labels = {
          app = var.app_label

          name = "wordpress-pod"
        }
      }

      spec {
        container {
          name  = "wordpress"
          image = "dimalenchuk/novinano:1"

          port {
            container_port = 80
          }
          env {
            name  = "MYSQL_DB_ADDRESS"
            value = kubernetes_service.mysql_service.spec[0].cluster_ip
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress_service" {
  metadata {
    name = "wordpress-service"

    labels = {
      app = var.app_label

      name = "wordpress-service"
    }
  }

  spec {
    load_balancer_ip = data.terraform_remote_state.gke_cluster.outputs.load_balancer_ip
    port {
      port        = 80
      target_port = "80"
    }

    selector = {
      app = var.app_label

      name = "wordpress-pod"
    }

    type = "LoadBalancer"
  }
}

output loadbalancer_ip {
  value       = kubernetes_service.wordpress_service.spec[0].load_balancer_ip
  description = "description"
  depends_on  = [kubernetes_service.wordpress_service]
}

output mysql_ip {
  value       = kubernetes_service.mysql_service.spec[0].cluster_ip
  description = "description"
  depends_on  = [kubernetes_service.mysql_service]
}

