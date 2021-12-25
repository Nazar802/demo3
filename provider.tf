
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "c1f655d1-f2ec-43ff-8d1c-56e2a8563483"
  tenant_id = "66fb062f-fc4a-4165-8f98-3407d5825883"
  client_id = "5df141fc-fd2b-4051-b9c4-d689adca90e5"
  client_secret = "f2u7Q~FdZVJn2Df~BNCevil64Rv7l_6gDEZL_"

}
resource "azurerm_resource_group" "rg" {
  name = "aks-rg"
  location = "eastus"
}
resource "azurerm_dns_zone" "k8s" {
  name                = "teachua.com"
  resource_group_name = azurerm_resource_group.k8s.name
}

resource "azurerm_public_ip" "k8s" {
  name                = "K8sPublick"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  allocation_method   = "Dynamic"
  ip_version          = "IPv4"
}

resource "azurerm_dns_a_record" "k8s" {
  name                = "teachua-demo3-new"
  name_servers        = "teach-ua-demo3-new"
  zone_name           = azurerm_dns_zone.k8s.name
  resource_group_name = azurerm_resource_group.k8s.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.k8s.id
}
resource "azurerm_dns_a_record" "k8s2" {
  name                = "teachua"
  zone_name           = azurerm_dns_zone.k8s.name
  name_servers        = "teach-ua-demo3-new"
  resource_group_name = azurerm_resource_group.k8s.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.k8s.id
}
