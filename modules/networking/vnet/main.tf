resource "azurerm_virtual_network" "this" {
  count               = var.turned_on ? 1 : 0
  name                = "${var.company}-${terraform.workspace}-vnet-${var.region}"
  location            = var.resource_group.name
  resource_group_name = var.resource_group.location
  address_space       = ["10.0.0.0/16"]

  tags = lookup(module.common.tags, terraform.workspace, null)
}
