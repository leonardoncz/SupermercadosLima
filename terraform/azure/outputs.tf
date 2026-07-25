output "vision_endpoint" {
  description = "Endpoint del servicio Azure AI Vision (usado por el script Python)"
  value       = azurerm_cognitive_account.vision.endpoint
}

output "vision_primary_key" {
  description = "Clave primaria de acceso al servicio (sensible; no imprimir en logs ni commitear)"
  value       = azurerm_cognitive_account.vision.primary_access_key
  sensitive   = true
}
