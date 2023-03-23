provider "kubernetes" {
  config_path    = var.config_path
  config_context = var.config_context
}

locals {
  namespace       = kubernetes_namespace.namespace.metadata.0.name
  service_account = kubernetes_service_account.service_account.metadata.0.name
  cluster_role    = kubernetes_cluster_role.cluster_role.metadata.0.name
  pvc             = kubernetes_persistent_volume_claim.pvc.metadata.0.name
  pv              = kubernetes_persistent_volume.pv.metadata.0.name

  labels = {
    env       = "test"
    owner     = "MykhailoPasiechnyk"
    terraform = "true"
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "python-job"

    labels = merge(local.labels, {
      resource = "namespace"
    })
  }
}

resource "kubernetes_service_account" "service_account" {
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
      "kubernetes.io/service-account.name" = local.service_account
    }

    labels = merge(local.labels, {
      resource = "secret"
    })
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role" "cluster_role" {
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

resource "kubernetes_cluster_role_binding" "cluster_role_binding" {
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
    name      = local.cluster_role
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.service_account
    namespace = local.namespace
  }
}

resource "kubernetes_cron_job_v1" "cron_job" {
  metadata {
    name      = "python-job"
    namespace = local.namespace

    labels = merge(local.labels, {
      resource = "CronJob"
    })
  }
  spec {
    concurrency_policy            = var.concurrency_policy
    failed_jobs_history_limit     = var.failed_jobs_history_limit
    schedule                      = var.job_schedule
    successful_jobs_history_limit = var.successful_jobs_history_limit
    starting_deadline_seconds     = var.starting_deadline_seconds
    job_template {
      metadata {}
      spec {
        backoff_limit = var.backoff_limit
        template {
          metadata {}
          spec {
            service_account_name = local.service_account
            container {
              name    = var.container_name
              image   = "${var.cron_job_image}:${var.image_tag}"
              command = var.container_entrypoint
              volume_mount {
                mount_path = "/data"
                name       = "python-volume"
              }
              resources {
                requests = var.job_resources_requests
                limits   = var.job_resources_limits
              }
            }
            volume {
              name = "python-volume"
              persistent_volume_claim {
                claim_name = local.pvc
              }
            }
            restart_policy = var.restart_policy
            image_pull_secrets {
              name = kubernetes_secret.python-sa-secret.metadata.0.name
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
    access_modes = var.pvc_access_modes
    resources {
      requests = var.pvc_resources_requests
    }
    volume_name        = local.pv
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
    access_modes = var.pv_access_modes
    capacity     = var.pv_capacity
    persistent_volume_reclaim_policy = var.pv_reclaim_policy
    storage_class_name               = "hostpath"
    persistent_volume_source {
      host_path {
        path = "/mnt/data"
      }
    }
  }
}
