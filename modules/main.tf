terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  client_id                  = "31bb97c1-d147-4645-8f79-94bb38cf6482"
  tenant_id                  = "1a721771-b78a-4079-9ec5-38695d718adb"
  subscription_id            = "64c864fc-0f94-49e8-8089-f3a2e31d1cfe"
  client_secret              = ".Rg7Q~Zt6r8zADkltkzitCAMES8~4WYg4F3jA"
  skip_provider_registration = true
  features {}
}
####


#### ??????????
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_subnet" "main" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_image" "image" {
  name                = "terraformtest-imagev1"
  resource_group_name = "terraform-test"
}

#### VM???

## NIC???
resource "azurerm_network_interface" "windows_nic" {
  name                = "${var.hostname}-nic1"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.main.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.IPAddress
  }

  tags = {
    server = "${var.hostname}"
  }
}

## VM???
resource "azurerm_virtual_machine" "windowsvm" {
  name                  = var.hostname
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  vm_size               = var.vmsize
  network_interface_ids = [azurerm_network_interface.windows_nic.id]
  delete_os_disk_on_termination = true
  tags = {
    server = "${var.hostname}"
  }

  os_profile {
    computer_name  = var.hostname
    admin_username = var.admin_username
    admin_password = "${var.hostname}abc"
  }
  os_profile_windows_config {
    enable_automatic_upgrades = false
    provision_vm_agent        = true
  }
  storage_image_reference {
    id = data.azurerm_image.image.id
  }
  storage_os_disk {
    name              = "${var.hostname}-osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.managed_disk_type
  }
}
