resource "azurerm_resource_group" "this" {
  count = var.turned_on ? 1 : 0
  name     = "${var.company}-${terraform.workspace}-rg-${var.region}"
  location = var.region

  tags = lookup(module.common.tags, terraform.workspace, null)
}

module "networking" {
  turned_on = var.turned_on
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.this.name
  resource_group_location = azurerm_resource_group.this.name

  region = var.region
}

module "common" {
  source = "./modules/common"
}