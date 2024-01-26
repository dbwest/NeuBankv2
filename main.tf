resource "azurerm_resource_group" "this" {
  count    = var.enable ? 1 : 0
  name     = "${var.company}-${terraform.workspace}-rg-${var.region}"
  location = var.region

  tags = lookup(module.common.tags, terraform.workspace, null)
}

module "network" {
  count  = var.enable ? 1 : 0
  source = "./modules/network"

  company = var.company
  region  = var.region
  rg_name = azurerm_resource_group.this[0].name
}

module "app_stack" {
  count  = var.enable ? 1 : 0
  source = "./modules/app_stack"

  company = var.company
  region  = var.region
  rg_name = azurerm_resource_group.this[0].name
}

module "db" {
  count  = 0
  source = "./modules/db"

  company   = var.company
  region    = var.region
  rg_name   = azurerm_resource_group.this[0].name
  vnet_name = module.network[0].vnet_name
}

module "common" {
  source = "./modules/common"
}

