output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "integration_subnet_id" {
  value = azurerm_subnet.integration.id
}

output "endpoint_subnet_id" {
  value = module.subnets.endpoint_subnet_id
}