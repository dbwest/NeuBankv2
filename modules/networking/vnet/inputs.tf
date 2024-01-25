variable "region" {
  type = string
}

variable "company" {
  type    = string
  default = "neubank"
}

variable "turned_on" {
  description = "whether to turned_on the env or not"
  type        = bool
  default     = false
}

variable "resource_group" {
  type = object({
    name     = self.name
    location = self.location
  })
}
