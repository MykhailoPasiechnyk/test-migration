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
    name      = "python-service-account"
    namespace = kubernetes_namespace.python-job.metadata[0].name
  }
}

resource "kubernetes_secret" "python-sa-secret" {
  metadata {
    name      = "python-sa-secret"
    namespace = kubernetes_namespace.python-job.metadata[0].name

    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.python-sa.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role" "pod-reader" {
  metadata {
    name = "pod-reader"

    labels = {
      env    = "test"
      target = "python-sa"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "pod-reader-rb" {
  metadata {
    name = "pod-reader-rb"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.pod-reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.python-sa.metadata[0].name
    namespace = kubernetes_namespace.python-job.metadata[0].name
  }
}

resource "kubernetes_cron_job_v1" "python-job" {
  metadata {
    name      = "python-job"
    namespace = kubernetes_namespace.python-job.metadata[0].name
  }
  spec {
    concurrency_policy            = "Allow"
    failed_jobs_history_limit     = 5
    schedule                      = "*/1 * * * *"
    successful_jobs_history_limit = 10
    starting_deadline_seconds     = 10
    job_template {
      metadata {}
      spec {
        backoff_limit = 2
        template {
          metadata {}
          spec {
            service_account_name = kubernetes_service_account.python-sa.metadata[0].name
            container {
              name    = "python-job"
              image   = "pasiechnyk/my-python:1.3"
              command = ["python", "/app/main.py"]
              resources {
                requests = {
                  memory = "128Mi"
                  cpu    = "500m"
                }
              }
            }
            restart_policy = "OnFailure"
            image_pull_secrets {
              name = kubernetes_secret.python-sa-secret.metadata[0].name
            }
          }
        }
      }
    }
  }
}
