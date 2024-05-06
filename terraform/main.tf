locals {
  location = "norwayeast"
}

resource "azurerm_resource_group" "devops" {
  name     = "${var.my_name}-rg"
  location = local.location
}

resource "azurerm_container_app_environment" "devops" {
  name                = "${azurerm_resource_group.devops.name}-env"
  location            = local.location
  resource_group_name = azurerm_resource_group.devops.name
}

resource "azurerm_container_app" "devops" {
  name                         = "${var.my_name}-app"
  container_app_environment_id = azurerm_container_app_environment.devops.id
  resource_group_name          = azurerm_resource_group.devops.name
  revision_mode                = "Single"

  template {
    # Task T.2:
    #
    # Answer T.2:
    container {
      name   = "devops-workshop"
      image  = "ghcr.io/${var.repository}/${var.my_name}:latest"
      cpu    = "0.25"
      memory = "0.5Gi"
    }
    #

    min_replicas    = 1
    max_replicas    = 1
    revision_suffix = substr(var.revision_suffix, 0, 10)
  }

  ingress {
    target_port      = "3000"
    external_enabled = true

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

output "container_app_url" {
  value = "https://${azurerm_container_app.devops.ingress.0.fqdn}"
}
