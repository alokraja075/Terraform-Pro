output "webapp_url" {
  description = "Public URL of the prod Azure Web App"
  value       = module.webapp.webapp_url
}