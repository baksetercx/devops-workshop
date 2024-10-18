locals {
  location = "westeurope"
}

resource "azurerm_resource_group" "devops" {
  name     = "${var.my_name}-rg"
  location = local.location
}

resource "azurerm_static_web_app" "devops" {
  name                = "${var.my_name}-webapp"
  # Task 2.2:
  location = azurerm_resource_group.devops.location
  resource_group_name = azurerm_resource_group.devops.name
}

output "resource_group_name" {
  value = azurerm_resource_group.devops.name
}

output "swa_name" {
  value = azurerm_static_web_app.devops.name
}

output "swa_url" {
  value = azurerm_static_web_app.devops.default_host_name
}
