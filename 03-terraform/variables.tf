variable "config_path" {
  type        = string
  description = "A path to a kube config file."
  default     = "~/.kube/config"
}

variable "config_context" {
  type        = string
  description = "Context to choose from the config file."
  default     = "docker-desktop"
}

#---------Cron Job----------#
variable "concurrency_policy" {
  type        = string
  description = "Specifies how to treat concurrent executions of a Job."
  default     = "Forbid"
}

variable "failed_jobs_history_limit" {
  type        = number
  description = "The number of failed finished jobs to retain."
  default     = 5
}

variable "job_schedule" {
  type        = string
  description = "The schedule in Cron format."
  default     = "*/5 * * * *"
}

variable "successful_jobs_history_limit" {
  type        = number
  description = "The number of successful finished jobs to retain."
  default     = 10
}

variable "starting_deadline_seconds" {
  type        = number
  description = "Deadline in seconds for starting the job if it misses scheduled time for any reason."
  default     = 10
}

variable "backoff_limit" {
  type        = number
  description = "Specifies the number of retries before marking this job failed."
  default     = 2
}

variable "container_name" {
  type        = string
  description = "The container name."
  default     = "python-job"
}

variable "cron_job_image" {
  type        = string
  description = "The image for cron job"
  default     = "pasiechnyk/my-python"
}

variable "image_tag" {
  type        = string
  description = "The tag for docker image."
  default     = "latest"
}

variable "container_entrypoint" {
  type        = list(string)
  description = "Entrypoint array."
  default     = ["python", "/app/main.py"]
}

variable "job_resources_requests" {
  type        = map(string)
  description = "Describes the minimum amount of compute resources required."
  default     = {
    memory = "128Mi"
    cpu    = "500m"
  }
}

variable "job_resources_limits" {
  type        = map(string)
  description = "Describes the maximum amount of compute resources allowed."
  default     = {
    memory = "256Mi"
    cpu    = "1"
  }
}

variable "restart_policy" {
  type        = string
  description = "Restart policy for all containers within the pod."
  default     = "OnFailure"
}


#----------PVC----------#
variable "pvc_access_modes" {
  type        = list(string)
  description = "A set of the desired access modes the volume should have."
  default     = ["ReadWriteMany"]
}

variable "pvc_resources_requests" {
  type        = map(string)
  description = "Describes the minimum amount of storage resources required."
  default     = {
    storage = "1Gi"
  }
}


#----------PV----------#
variable "pv_access_modes" {
  type        = list(string)
  description = "A set of the desired access modes the volume should have."
  default     = ["ReadWriteMany"]
}

variable "pv_capacity" {
  type        = map(string)
  description = "A description of the persistent volume's resources and capacity."
  default     = {
    storage = "1Gi"
  }
}

variable "pv_reclaim_policy" {
  type        = string
  description = "What happens to a persistent volume when released from its claim."
  default     = "Retain"
}