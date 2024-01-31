output "administrator_login_password" {
  description = "Managed SQL Server Admin Login Password"
  value       = azurerm_mssql_managed_instance.db.administrator_login_password
  sensitive   = true
}