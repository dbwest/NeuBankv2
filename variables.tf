variable "region" {
  type = string
}

variable "company" {
  type    = string
  default = "neubank"
}

variable "enable" {
  description = "Turn env on?"
  type        = bool
  default     = false
}

variable "expose_presentation_tier" {
  description = "Expose presentation tier to public internet?"
  type        = bool
  default     = false
}