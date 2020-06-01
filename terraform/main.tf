terraform {
  required_version = ">= 0.12"

  backend "remote" {
    organization = "cdwms"

    workspaces {
      name = "appsvc-github-actions"
    }
  }
}

provider "azurerm" {
  version = "~> 2.12"
  features {}
}

variable "name" {
  type        = string
  description = "The base name to use for naming resources."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be created."
}

resource "azurerm_resource_group" "group" {
  name     = var.name
  location = var.location
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${var.name}-plan"
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  kind                = "Linux"
  reserved            = true

  sku {
    tier     = "Basic"
    capacity = 1
  }
}

resource "azurerm_app_service" "app" {
  name                = var.name
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  app_service_plan_id = azurerm_app_service_plan.plan.id
  
  site_config {
    always_on          = true
    linux_fx_version = "DOTNETCORE|3.1"
  }
}