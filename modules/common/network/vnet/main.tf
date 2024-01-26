resource "azurerm_virtual_network" "this" {
  name                = "${var.company}-${terraform.workspace}-vnet-${var.region}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]

  tags = lookup(module.common.tags, terraform.workspace, null)
}