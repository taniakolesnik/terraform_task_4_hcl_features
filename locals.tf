locals {
  security_rules = {
    "storage1" = { "name" = "one-sg", "priority" = 1001, "direction" = "Inbound", "access" = "Allow", "protocol" = "Tcp", "source_port_range" = "*", "destination_port_range" = "22" },
    "storage2" = { "name" = "two-sg", "priority" = 1002, "direction" = "Inbound", "access" = "Allow", "protocol" = "Tcp", "source_port_range" = "*", "destination_port_range" = "22" },
    "storage3" = { "name" = "three-sg", "priority" = 1004, "direction" = "Inbound", "access" = "Allow", "protocol" = "Tcp", "source_port_range" = "*", "destination_port_range" = "22" }
  }
}

locals {
  network_interface_names = [
    for nic in azurerm_network_interface.main :
    nic.name
  ]
}

locals {
  network_names = ["one", "two", "three", "four"]
}