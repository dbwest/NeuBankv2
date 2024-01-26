module "vnet" {
  source = "./vnet"

  company = var.company
  region  = var.region
}