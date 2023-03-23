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