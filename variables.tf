variable "resource_tags" {
  description = "tag names for the resources"
  type        = map(string)
  default = {
    "env"     = "devs"
    "project" = "demo"
  }
}

