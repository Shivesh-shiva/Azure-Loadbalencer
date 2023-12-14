data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.rgname
}

data "azurerm_virtual_machine" "vm" {
  for_each            = var.bknd
  name                = each.value.vmname
  resource_group_name = var.rgname
}



