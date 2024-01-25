resource "azurerm_resource_group" "this" {
  count = var.deploy ? 1 : 0
  name     = "${var.company}-${terraform.workspace}-rg-${var.region}"
  location = var.region

  tags = lookup(module.common.tags, terraform.workspace, null)
}

module "common" {
  source = "./modules/common"
}