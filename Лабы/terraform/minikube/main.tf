provider "kubernetes" {
  config_context = "${terraform.workspace == "default" ? "minikube" : "gke_tutorial"}"
}

resource "kubernetes_replication_controller" "echo" {
  metadata {
    name = "echo-example"

    labels {
      app = "echo_app"
    }
  }

  spec {
    selector {
      app = "echo_app"
    }
    template {
      container {
        image = "hashicorp/http-echo:0.2.1"
        name  = "example2"
        args = ["-listen=:88", "-text='${var.text}'"]

        port {
          container_port = 88
        }
        resources{
          limits{
            cpu = "500m"
            memory = "512Mi"
          }
          requests{
            cpu = "250m"
            memory = "50Mi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "echo" {
  metadata {
    name = "echo-example"
  }

  spec {
    selector {
      app = "${kubernetes_replication_controller.echo.metadata.0.labels.app}"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 88
    }

    type = "${terraform.workspace == "default" ? "NodePort" : "LoadBalancer"}"
  }
}