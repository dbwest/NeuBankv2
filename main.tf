resource "azurerm_resource_group" "this" {
  count = var.turned_on ? 1 : 0
  name     = "${var.company}-${terraform.workspace}-rg-${var.region}"
  location = var.region

  tags = lookup(module.common.tags, terraform.workspace, null)
}

module "vnet" {
  source = "./modules/networking/vnet"

  resource_group = azurerm_resource_group.this
  turned_on = var.turned_on
  region = var.region
}

module "common" {
  source = "./modules/common"
}