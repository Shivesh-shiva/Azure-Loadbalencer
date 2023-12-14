resource "azurerm_public_ip" "lb_pip" {
  name                = var.lbpip_name
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "LB" {
  name                = var.lbname
  location            = var.location
  resource_group_name = var.rgname
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LB-PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "BackEndAddressPool"
  loadbalancer_id = azurerm_lb.LB.id
}

resource "azurerm_lb_backend_address_pool_address" "backend_address" {
  for_each                = var.bknd
  name                    = each.value.backend_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
  virtual_network_id      = data.azurerm_virtual_network.vnet.id
  ip_address              = data.azurerm_virtual_machine.vm[each.key].private_ip_address
}


resource "azurerm_lb_probe" "pb" {
  loadbalancer_id = azurerm_lb.LB.id
  name            = "Lb-probe"
  port            = 22
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.LB.id
  name                           = "nginx_LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LB-PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.pb.id
}