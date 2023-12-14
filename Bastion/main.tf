data "azurerm_subnet" "bstion_subnet" {
  name                 = var.bastionsubnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rgname
}


resource "azurerm_public_ip" "bastion_pip" {
  name                = var.pip_name
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.rgname

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.bstion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}