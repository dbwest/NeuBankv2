# tags could alternately be handled as inputs on the root main.tf
variable "common_tags" {
  description = "Required Tags for Resources"
  type = map(object({
    Environment = string
    Owner       = string
    Project     = string
  }))
  default = {
    "dev" = {
      Environment = "Dev"
      Owner       = "first.last@company.com"
      Project     = "Mortgage Calculator"
    }
    "test" = {
      Environment = "Test"
      Owner       = "first.last@company.com"
      Project     = "Mortgage Calculator"
    }
    "prod" = {
      Environment = "Prod"
      Owner       = "first.last@company.com"
      Project     = "Mortgage Calculator"
    }
  }
}
