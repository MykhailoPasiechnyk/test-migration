provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

locals {
  namespace = kubernetes_namespace.python-job.metadata[0].name
  labels    = {
    env       = "test"
    owner     = "MykhailoPasiechnyk"
    terraform = "true"
  }
}

resource "kubernetes_namespace" "python-job" {
  metadata {
    name = "python-job"

    labels = merge(local.labels, {
      resource = "namespace"
    })
  }
}

resource "kubernetes_service_account" "python-sa" {
  metadata {
    name      = "python-service-account"
    namespace = local.namespace

    labels = merge(local.labels, {
      resource = "service-account"
    })
  }
}

resource "kubernetes_secret" "python-sa-secret" {
  metadata {
    name      = "python-sa-secret"
    namespace = local.namespace

    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.python-sa.metadata[0].name
    }

    labels = merge(local.labels, {
      resource = "secret"
    })
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role" "pod-reader" {
  metadata {
    name = "pod-reader"

    labels = merge(local.labels, {
      resource = "ClusterRole"
    })
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

    labels = merge(local.labels, {
      resource = "ClusterRoleBinding"
      role     = "pod-reader"
      target   = "python-sa"
    })
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.pod-reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.python-sa.metadata[0].name
    namespace = local.namespace
  }
}

resource "kubernetes_cron_job_v1" "python-job" {
  metadata {
    name      = "python-job"
    namespace = local.namespace

    labels = merge(local.labels, {
      resource = "CronJob"
    })
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
              image   = "pasiechnyk/my-python"
              command = ["python", "/app/main.py"]
              volume_mount {
                mount_path = "/data"
                name       = "python-volume"
              }
              resources {
                requests = {
                  memory = "128Mi"
                  cpu    = "500m"
                }
              }
            }
            volume {
              name = "python-volume"
              persistent_volume_claim {
                claim_name = kubernetes_persistent_volume_claim.pvc.metadata[0].name
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

resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name      = "python-pvc"
    namespace = local.namespace

    labels = merge(local.labels, {
      resource = "pvc"
    })
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name        = kubernetes_persistent_volume.pv.metadata[0].name
    storage_class_name = "hostpath"
  }
}

resource "kubernetes_persistent_volume" "pv" {
  metadata {
    name = "python-pv"

    labels = merge(local.labels, {
      resource = "pv"
    })
  }
  spec {
    access_modes = ["ReadWriteMany"]
    capacity     = {
      storage = "1Gi"
    }
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "hostpath"
    persistent_volume_source {
      host_path {
        path = "/mnt/data"
      }
    }
  }
}
