resource "azurerm_resource_group" "rg" {
  for_each = var.rgname
  name     = each.key
  location = each.value.location
}