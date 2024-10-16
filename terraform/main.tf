locals {
  location = "norwayeast"
}

resource "azurerm_resource_group" "devops" {
  name     = "${var.my_name}-rg"
  location = local.location
}

resource "azurerm_static_web_app" "devops" {
  name                = "${var.my_name}-webapp"
  resource_group_name = azurerm_resource_group.devops.name
  location            = local.location
}

output "swa_api_key" {
  value     = azurerm_static_web_app.devops.api_key
  sensitive = true
}
