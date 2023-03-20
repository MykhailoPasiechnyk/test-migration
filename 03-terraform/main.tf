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
