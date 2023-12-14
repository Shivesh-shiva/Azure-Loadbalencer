data "azurerm_key_vault" "kvault" {
  name                = var.kvname
  resource_group_name = var.rgname
}

data "azurerm_key_vault_secret" "sec1" {
  name         = var.sec1
  key_vault_id = data.azurerm_key_vault.kvault.id
}

data "azurerm_key_vault_secret" "sec2" {
  name         = var.sec2
  key_vault_id = data.azurerm_key_vault.kvault.id
}

data "azurerm_subnet" "vn1" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rgname
}



resource "azurerm_network_interface" "nic" {
  for_each            = var.virtual_machine
  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = var.rgname

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.vn1.id
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_linux_virtual_machine" "example" {
  for_each                        = var.virtual_machine
  name                            = each.value.vmname
  resource_group_name             = var.rgname
  location                        = each.value.location
  size                            = each.value.size
  admin_username                  = data.azurerm_key_vault_secret.sec1.value
  admin_password                  = data.azurerm_key_vault_secret.sec2.value
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}