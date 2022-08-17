output "id" {
  value       = azurerm_api_management.apim.id
  description = "The ID of the API Management Service."
}

output "private_ip_addresses" {
  value       = azurerm_api_management.apim.private_ip_addresses
  description = "The Private IP addresses of the API Management Service."
}

output "public_ip_addresses" {
  value       = azurerm_api_management.apim.public_ip_addresses
  description = "The Public IP addresses of the API Management Service."
}

output "identity" {
  value       = azurerm_api_management.apim.identity
  description = "An identity block as defined below."
}
