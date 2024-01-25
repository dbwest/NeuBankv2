module "vnet" {
  source = "./vnet"

  resource_group_name = azurerm_resource_group.this.name
  resource_group_location = azurerm_resource_group.this.name

  turned_on = var.turned_on
  region = var.region
}