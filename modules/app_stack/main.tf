resource "azurerm_service_plan" "this" {
  name                = "${var.company}-${terraform.workspace}-appserviceplan-${var.region}"
  location            = var.region
  resource_group_name = var.rg_name
  os_type             = "Windows"
  sku_name            = "P1v2"

  tags = lookup(module.common.tags, terraform.workspace, null)
}

resource "azurerm_windows_web_app" "frontend" {
  name                = "${var.company}-${terraform.workspace}-frontend-${var.region}"
  location            = var.region
  resource_group_name = var.rg_name
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true
  # Assuming here the presentation tier should be exposed on the public internet
  # If this app's presentation tier should be internal only you can set the following to false
  public_network_access_enabled = var.expose_presentation_tier
  site_config {
    vnet_route_all_enabled = true
  }

  app_settings = {
    # facilitates communications to Azure platform resources for various things
    # - health checks
    # - DHCP
    # - Guest Agent heartbeat messages
    "WEBSITE_DNS_SERVER" : "168.63.129.16"
    # hook in app insights
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = var.app_insights_instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
  }

  tags = lookup(module.common.tags, terraform.workspace, null)
}

resource "azurerm_windows_web_app" "backend" {
  name                          = "${var.company}-${terraform.workspace}-backend-${var.region}"
  location                      = var.region
  resource_group_name           = var.rg_name
  service_plan_id               = azurerm_service_plan.this.id
  https_only                    = true
  public_network_access_enabled = false

  site_config {
  }

  app_settings = {
    # hook in app insights
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = var.app_insights_instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
  }

  tags = lookup(module.common.tags, terraform.workspace, null)
}

# include common module for tagging
module "common" {
  source = "../common"
}
