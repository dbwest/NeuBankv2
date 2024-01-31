resource "azurerm_virtual_network" "this" {
  name                = "${var.company}-${terraform.workspace}-vnet-${var.region}"
  location            = var.region
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]

  tags = lookup(module.common.tags, terraform.workspace, null)
}

resource "azurerm_network_security_group" "vnet" {
  name                = "${var.company}-${terraform.workspace}-vnetnsg-${var.region}"
  location            = var.region
  resource_group_name = var.rg_name

  tags = lookup(module.common.tags, terraform.workspace, null)
}

# Prevent exfiltration of data
# see https://learn.microsoft.com/en-us/azure/app-service/overview-private-endpoint#conceptual-overview
resource "azurerm_network_security_rule" "vnet_deny_outbound" {
  name                        = "vnet_deny_all_outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.vnet.name
}

# exists for backend access internally by devs
resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.rg_name

  tags = lookup(module.common.tags, terraform.workspace, null)
}

module "subnets" {
  source = "./subnets"

  company              = var.company
  region               = var.region
  rg_name              = var.rg_name
  virtual_network_name = azurerm_virtual_network.this.name
}

module "endpoints" {
  source = "./endpoints"

  company               = var.company
  region                = var.region
  rg_name               = var.rg_name
  endpoint_subnet_id    = module.subnets.endpoint_subnet_id
  private_dns_zone_id   = azurerm_private_dns_zone.this.id
  backend_id            = var.backend_id
  frontend_id           = var.frontend_id
  integration_subnet_id = module.subnets.integration_subnet_id
}

module "common" {
  source = "../common"
}