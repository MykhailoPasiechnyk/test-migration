provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

resource "kubernetes_namespace" "python-job" {
  metadata {
    name = "python-job"

    labels = {
      type = "namespace"
      env  = "test"
    }
  }
}

resource "kubernetes_service_account" "python-sa" {
  metadata {
    name = "python-service-account"
  }
}

resource "kubernetes_role" "pod-reader" {
  metadata {
    name      = "pod-reader"
    namespace = kubernetes_namespace.python-job.metadata[0].name

    labels = {
      env    = "test"
      target = "python-sa"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}
