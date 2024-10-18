locals {
  location = "westeurope"
}

resource "azurerm_resource_group" "devops" {
  name     = "${var.my_name}-rg"
  location = local.location
}

resource "azurerm_static_web_app" "devops" {
  name                = "${var.my_name}-webapp"
  location = "westeurope"
  resource_group_name = "ellens_resource"
  # Task 2.2:
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
