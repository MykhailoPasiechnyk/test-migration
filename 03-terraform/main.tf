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

  secret {
    name = kubernetes_secret.python-sa-secret.metadata[0].name
  }

}

resource "kubernetes_secret" "python-sa-secret" {
  metadata {
    name = "python-secret"
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

resource "kubernetes_role_binding" "pod-reader-rb" {
  metadata {
    name = "pod-reader-rb"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.pod-reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.python-sa.metadata[0].name
    namespace = kubernetes_namespace.python-job.metadata[0].name
  }
}
