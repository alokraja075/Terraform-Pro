output "webapp_url" {
  description = "Public URL of the deployed Azure Web App"
  value       = "https://${azurerm_linux_web_app.webapp.default_hostname}"
}

output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "service_plan_name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.plan.name
}