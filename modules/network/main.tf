resource "azurerm_virtual_network" "neubank" {
  name                = "${var.company}-${terraform.workspace}-vnet-${var.region}"
  location            = var.region
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]

  tags = lookup(module.common.tags, terraform.workspace, null)
}

resource "azurerm_network_security_group" "neubank" {
  name                = "${var.company}-${terraform.workspace}-nbknsg-${var.region}"
  location            = azurerm_resource_group.neubank.location
  resource_group_name = azurerm_resource_group.neubank.name
}

resource "azurerm_subnet_network_security_group_association" "neubank" {
  subnet_id                 = azurerm_subnet.neubank.id
  network_security_group_id = azurerm_network_security_group.neubank.id
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.rg_name

  tags = lookup(module.common.tags, terraform.workspace, null)
}

resource "azurerm_app_service_virtual_network_swift_connection" "frontend" {
  app_service_id = var.frontend_id
  subnet_id      = module.subnets.integration_subnet_id
}

module "subnets" {
  source = "./subnets"

  company              = var.company
  region               = var.region
  rg_name              = var.rg_name
  virtual_network_name = azurerm_virtual_network.neubank.name
}

module "endpoints" {
  source = "./endpoints"

  company             = var.company
  region              = var.region
  rg_name             = var.rg_name
  endpoint_subnet_id  = module.subnets.endpoint_subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.this.id
  backend_id          = var.backend_id
}

module "common" {
  source = "../common"
}