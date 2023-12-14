resource "azurerm_virtual_network" "virtualnetwork" {
  name                = var.network_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.address_space


  dynamic "subnet" {
    for_each = var.subnets

    content {
      name           = subnet.value.subnet_name
      address_prefix = subnet.value.subnet_address
    }

  }

}




