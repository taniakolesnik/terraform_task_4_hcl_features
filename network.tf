resource "azurerm_virtual_network" "main" {
  for_each = toset(local.network_names)

  name                = "${var.prefix}-${each.key}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "internal" {
  for_each = azurerm_virtual_network.main

  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = each.value.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  for_each = azurerm_subnet.internal

  name                = "${var.prefix}-${each.key}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = each.value.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  dynamic "security_rule" {
    for_each = local.security_rules
    content {
      name                   = security_rule.value.name
      priority               = security_rule.value.priority
      direction              = security_rule.value.direction
      access                 = security_rule.value.access
      protocol               = security_rule.value.protocol
      source_port_range      = security_rule.value.source_port_range
      destination_port_range = security_rule.value.destination_port_range
    }
  }
}

resource "azurerm_virtual_machine" "main" {
  count               = 2
  name                = "${var.prefix}-${count.index}-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  network_interface_ids = [
    azurerm_network_interface.main[
      local.network_interface_names[count.index]
    ].id
  ]
  vm_size = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }

  lifecycle {
    prevent_destroy = true
  }
}