resource "random_string" "sac" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_storage_account" "blob" {
  name                            = "${random_string.sac.result}${var.company}${terraform.workspace}storacc${var.region}"
  resource_group_name             = var.rg_name
  location                        = var.region
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false

  tags = lookup(module.common.tags, terraform.workspace, null)
}

resource "azurerm_storage_container" "blob" {
  name                  = "${var.company}-${terraform.workspace}-sc-${var.region}"
  storage_account_name  = azurerm_storage_account.blob.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob" {
  name                   = "rr123.gif"
  storage_account_name   = azurerm_storage_account.blob.name
  storage_container_name = azurerm_storage_container.blob.name
  type                   = "Block"
}

module "common" {
  source = "../common"
}