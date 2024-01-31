resource "azurerm_subnet" "endpoint" {
  name                 = "${var.company}-${terraform.workspace}-endpoint-subnet-${var.region}"
  resource_group_name  = var.rg_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.2.0/24"]
  # The blob storage needs a service endpoint
  # Users are forced to go through the backend when uploading and could
  # - have an interface that allows them to upload to blob storage in the presentation tier
  # - then be prevented further down the line from uploading malware or bad data by means of protection from antimalware or validation 
  private_endpoint_network_policies_enabled = true
  service_endpoints                         = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "integration" {
  name                 = "${var.company}-${terraform.workspace}-integration-subnet-${var.region}"
  resource_group_name  = var.rg_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.1.0/24"]
  # Enable virtual network integration in Azure App Service
  # See https://learn.microsoft.com/en-us/azure/app-service/configure-vnet-integration-enable
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}