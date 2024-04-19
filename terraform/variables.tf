variable "my_name" {
  required    = true
  type        = string
  description = "Your name. Must be lowercase and only a-z."
}

variable "revision_suffix" {
  required    = true
  type        = string
  description = "Unique suffix to differentiate versions of container in the container app, use e.g. git SHA."
}
