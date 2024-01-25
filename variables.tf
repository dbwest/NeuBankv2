variable "region" {
  type = string
}

variable "company" {
  type = string
  default = "neubank"
}

variable "turned_on" {
  description = "whether the env is turned on (should be deployed) or not"
  type = bool
  default = false
}