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

variable "cron_job_image" {
  type        = string
  description = "The image for cron job"
  default     = "pasiechnyk/my-python"
}