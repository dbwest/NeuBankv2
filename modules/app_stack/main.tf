resource "azurerm_service_plan" "this" {
  name                = "${var.company}-${terraform.workspace}-appserviceplan-${var.region}"
  location            = var.region
  resource_group_name = var.rg_name
  os_type             = "Windows"
  sku_name            = "P1v2"

  tags = lookup(module.common.tags, terraform.workspace, null)
}

resource "azurerm_windows_web_app" "frontend" {
  name                          = "${var.company}-${terraform.workspace}-frontend-${var.region}"
  location                      = var.region
  resource_group_name           = var.rg_name
  service_plan_id               = azurerm_service_plan.this.id
  https_only                    = true
  public_network_access_enabled = false

  site_config {
    vnet_route_all_enabled = true
  }

  app_settings = {
    WEBSITE_VNET_ROUTE_ALL = 1
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
    vnet_route_all_enabled = true
  }

  app_settings = {
    WEBSITE_VNET_ROUTE_ALL = 1
  }

  tags = lookup(module.common.tags, terraform.workspace, null)
}

module "common" {
  source = "../common"
}
