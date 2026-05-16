terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.105.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "prefix" {
  default = "tfvmex"
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

output "machine_name" {
  value = [
    for vm in azurerm_virtual_machine.main :
    upper(vm.name)
  ]
}

variable "tags" {
  default = {
    environment = "dev"
    owner       = "tania"
    project     = "terraform"
  }
}

output "tags" {
  value = join(", ", values(var.tags))
}

output "vm_ids" {
  value = [
    for vm in azurerm_virtual_machine.main :
    vm.id
  ]
}