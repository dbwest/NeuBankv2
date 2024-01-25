module "vnet" {
  source = "./vnet"

  resource_group_name = var.resource_group_name
  resource_group_location = var.resource_group_location

  turned_on = var.turned_on
  region = var.region
}