output "read_proxy_url" {
  value = azurerm_linux_function_app.read_proxy_function.default_hostname
}

output "archive_function_url" {
  value = azurerm_linux_function_app.archive_function.default_hostname
}
