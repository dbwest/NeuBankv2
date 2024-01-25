locals {
  resource_group_name    = "${var.github_user_name}-${var.github_repository}-${random_integer.sa_num.result}"
  storage_account_name   = "${lower(var.github_user_name)}${lower(var.github_repository)}${random_integer.sa_num.result}"
  sas_account_name       = "${lower(var.github_user_name)}${lower(var.github_repository)}${random_integer.sa_num.result}sas"
  service_principal_name = "${var.github_user_name}-${var.github_repository}-${random_integer.sa_num.result}"
}

data "azurerm_subscription" "current" {}

data "azuread_client_config" "current" {}

resource "azuread_application" "gh_actions" {
  display_name = local.service_principal_name
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "gh_actions" {
  client_id = azuread_application.gh_actions.application_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "gh_actions" {
  service_principal_id = azuread_service_principal.gh_actions.object_id
}

resource "azurerm_role_assignment" "gh_actions" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.gh_actions.id
}

# Azure Storage Account

resource "random_integer" "sa_num" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "setup" {
  name     = local.resource_group_name
  location = var.azure_location
}

# resource "azurerm_storage_account" "sa" {
#   name                     = local.storage_account_name
#   resource_group_name      = azurerm_resource_group.setup.name
#   location                 = var.azure_location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   # After bootstrapping and creating workspaces you can uncomment this and run the
#   # `Update Remote State and Actions Secrets with Terraform` Github Action

#   # public_network_access_enabled = false
# }

# data "azurerm_storage_account_sas" "sas" {
#   connection_string = azurerm_storage_account.sa.primary_connection_string
#   https_only        = true

#   resource_types {
#     service   = true
#     container = false
#     object    = false
#   }

#   services {
#     blob  = true
#     queue = false
#     table = false
#     file  = false
#   }

#   start  = "2018-03-21T00:00:00Z"
#   expiry = "2025-03-21T00:00:00Z"

#   permissions {
#     read    = true
#     write   = true
#     delete  = true
#     list    = true
#     add     = true
#     create  = true
#     update  = true
#     process = true
#     tag     = true
#     filter  = true
#   }
# }

# resource "azurerm_storage_container" "ct" {
#   name                 = "terraform-state"
#   storage_account_name = azurerm_storage_account.sa.name
# }

## GitHub secrets

resource "github_actions_secret" "actions_secret" {
  for_each = {
    # STORAGE_ACCOUNT     = azurerm_storage_account.sa.name
    # RESOURCE_GROUP      = azurerm_storage_account.sa.resource_group_name
    # CONTAINER_NAME      = azurerm_storage_container.ct.name
    ARM_CLIENT_ID       = azuread_service_principal.gh_actions.application_id
    ARM_CLIENT_SECRET   = azuread_service_principal_password.gh_actions.value
    ARM_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
    ARM_TENANT_ID       = data.azuread_client_config.current.tenant_id
    TF_API_TOKEN        = var.tfe_token
    # ARM_SAS_TOKEN       = data.azurerm_storage_account_sas.sas.sas
  }

  repository      = var.github_repository
  secret_name     = each.key
  plaintext_value = each.value
}

resource "tfe_organization" "this" {
  name  = lower(var.github_repository)
  email = var.admin_email
}

variable "environments" {
  description = "List of environments"
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

resource "tfe_workspace" "workspace" {
  for_each = toset(var.environments)

  name         = each.value
  organization = lower(var.github_repository)
  tag_names    = [each.value, "app"]
}

resource "tfe_variable" "arm_client_id" {
  for_each = toset(var.environments)

  key          = "ARM_CLIENT_ID"
  value        = azuread_service_principal.gh_actions.application_id
  category     = "env"
  workspace_id = tfe_workspace.workspace[each.key].id
  description  = "Azure Resource Manager Client Id"
}

resource "tfe_variable" "arm_subscription_id" {
  for_each = toset(var.environments)

  key          = "ARM_SUBSCRIPTION_ID"
  value        = data.azurerm_subscription.current.subscription_id
  category     = "env"
  workspace_id = tfe_workspace.workspace[each.key].id
  description  = "Azure Resource Manager Subscription Id"
}

resource "tfe_variable" "arm_client_secret" {
  for_each = toset(var.environments)

  key          = "ARM_CLIENT_SECRET"
  value        = azuread_service_principal_password.gh_actions.value
  category     = "env"
  workspace_id = tfe_workspace.workspace[each.key].id
  description  = "Azure Resource Client Secret"
  sensitive    = true
}

resource "tfe_variable" "arm_tenant_id" {
  for_each = toset(var.environments)

  key          = "ARM_TENANT_ID"
  value        = data.azuread_client_config.current.tenant_id
  category     = "env"
  workspace_id = tfe_workspace.workspace[each.key].id
  description  = "Azure Resource Tenant ID"
}

resource "null_resource" "local-provisioner" {
  provisioner "local-exec" {
    command = <<EOF
 
      echo 'export ARM_CLIENT_ID=${azuread_service_principal.gh_actions.application_id}' >> ../.env
      echo 'export ARM_CLIENT_SECRET=${azuread_service_principal_password.gh_actions.value}' >> ../.env
      echo 'export ARM_SUBSCRIPTION_ID=${data.azurerm_subscription.current.subscription_id}' >> ../.env
      echo 'export ARM_TENANT_ID=${data.azuread_client_config.current.tenant_id}' >> ../.env
    EOF
  }
}
