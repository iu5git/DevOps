terraform {
  required_version = ">= 0.11.14"
}

locals {
  tag          = "tf"
  default_type = "NodePort"

  namespace    = "${var.app}-ns"
  app          = "${var.app}-app"
}

resource "kubernetes_namespace" "ns" {
  metadata {
    annotations ={
      name = "${var.app}-annotation"
    }
    labels ={
      created_by = "terraform"
    }
    name = "${local.namespace}"
  }
}

resource "kubernetes_pod" "pod" {
  metadata {
    name = "${var.app}-pod"
    namespace = "${local.namespace}"
    labels ={
      app = "${var.app}-app"
    }
  }
  spec {
    container {
      image = "${var.container_image}:${var.container_version}"
      name  = "${local.tag}-${var.app}"
      port {
        container_port = "${var.container_port}"
      }
    }
  }
}

resource "kubernetes_service" "srv" {
  metadata {
    name = "${var.app}-srv"
    namespace = "${local.namespace}"
  }
  spec {
    selector ={
      app = "${kubernetes_pod.pod.metadata.0.labels.app}"
    }
    port {
      port = "${var.container_port}"
    }
    type = "${local.default_type}"
  }
}
