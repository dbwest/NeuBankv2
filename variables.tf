variable "region" {
  type = string
}

variable "company" {
  type = string
  default = "neubank"
}

variable "deploy" {
  description = "whether to deploy the env or not"
  type = bool
  default = false
}