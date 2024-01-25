resource "azurerm_resource_group" "this" {
  count = var.turned_on ? 1 : 0
  name     = "${var.company}-${terraform.workspace}-rg-${var.region}"
  location = var.region

  tags = lookup(module.common.tags, terraform.workspace, null)
}

module "networking" {
  count = var.turned_on ? 1 : 0
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.this[0].name
  resource_group_location = azurerm_resource_group.this[0].location

  region = var.region
  turned_on = var.turned_on
}

module "common" {
  source = "./modules/common"
}