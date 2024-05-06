variable "my_name" {
  type        = string
  description = "Your name. Must be lowercase and only a-z."
}

variable "repository" {
  type        = string
  description = "GitHub repository to use for the GHCR image."
}

variable "revision_suffix" {
  type        = string
  description = "Unique suffix to differentiate versions of container in the container app, use e.g. git SHA."
}
