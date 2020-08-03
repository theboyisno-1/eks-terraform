provider "kubernetes" {}

# Namespace
resource "kubernetes_namespace" "namespace" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

# Deployment 
resource "kubernetes_deployment" "deployment" {
  metadata {
    name        =   var.application_name
    namespace   =   var.namespace
    labels      =   var.deployment_labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = var.deployment_labels
    }

    strategy {
        type = "RollingUpdate"
        rolling_update {
            max_surge       = "2"
            max_unavailable = "0"
        }
    }

    template {
      metadata {
        labels = var.deployment_labels
      }

      spec {
        container {
          image = var.container_image
          name  = var.application_name

          port {
            container_port  = var.container_port
          }

          resources {
            limits {
              cpu    = var.container_resources_cpu_limit
              memory = var.container_resources_memory_limit
            }
            requests {
              cpu    = var.container_resources_cpu_requested
              memory = var.container_resources_memory_requested
            }
          }

          readiness_probe {
            tcp_socket {
              port  =    var.container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

# Service to expose app using LoadBalancer
resource "kubernetes_service" "service" {
  metadata {
    name        =   var.application_name
    namespace   =   var.namespace
  }
  spec {
    selector = var.deployment_labels
    port {
      port        = var.service_port
      target_port = var.container_port
    }
    type = var.service_type
  }
}

# HPA to scale application
resource "kubernetes_horizontal_pod_autoscaler" "hpa" {
  metadata {
    name        =   var.application_name
    namespace   =   var.namespace
  }

  spec {
    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas

    scale_target_ref {
      kind          = var.hpa_scale_target_ref_kind
      api_version   = var.hpa_scale_target_ref_api_version
      name          = var.application_name
    }

    metric {
      type = "Resource"
      resource {
          name = "cpu"
          target {
              type                  =   "Utilization"
              average_utilization   =   var.hpa_cpu_average_utilization
          }
      }
    }

    metric {
      type = "Resource"
      resource {
          name = "memory"
          target {
              type                  =   "Utilization"
              average_utilization   =   var.hpa_memory_average_utilization
          }
      }
    }
  }
}