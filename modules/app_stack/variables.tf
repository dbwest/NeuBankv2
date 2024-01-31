variable "company" {
  type = string
}

variable "region" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "app_insights_instrumentation_key" {
  type = string
}

variable "app_insights_connection_string" {
  type = string
}

variable "expose_presentation_tier" {
  description = "Expose presentation tier to public internet?"
  type        = bool
  default     = false
}