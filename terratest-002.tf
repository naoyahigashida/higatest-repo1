terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#### データリソースの設定
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

#### VMの設定

## NICを作る
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

## VMを作る
resource "azurerm_windows_virtual_machine" "windows" {
  name                  = var.hostname
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  size                  = var.vmsize
  admin_username        = "localadmin"
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.windows_nic.id]
  tags = {
    server = "${var.hostname}"
  }

  os_profile {
    computer_name  = var.hostname
    admin_username = "localadmin"
    admin_password = "${var.hostname}abc"
  }
  os_profile_windows_config {
    enable_automatic_upgrades = false
    provision_vm_agent        = false
  }
  storage_image_reference {
    id = data.azurerm_image.tf_name_vmimage.id
  }
  storage_os_disk {
    name              = "${var.hostname}-osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.managed_disk_type
    tags = {
      server = "${var.hostname}"
    }
  }
}

resource "azurerm_virtual_machine_extension" "windows_custom_script" {
  name                 = "extension-windows"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute":"powershell -ExecutionPolicy Unrestricted -File Install-zabbix-agent.ps1",
        "fileUris": ["https://gist.githubusercontent.com/jacopen/c33657b2c582f1ff8f2c86792b94e5ec/raw/cbd761c8c562a93082f374307b4450b4eb9de6eb/Install-zabbix-agent.ps1"]
    }
SETTINGS
}


#### 変数の宣言

## ほぼ固定

variable "vnet_name" {
  default = "vnet2"
}

variable "vnet_resource_group_name" {
  default = "PoC-virtualwanrg"
}


## サーバ毎

# サーバ名
variable "hostname" {
  default = "terratest-002"
}

# サーバと関連リソースが属するリソースグループ
variable "resource_group_name" {
  default = "terraform-test2"
}

# サーバを接続するサブネット
variable "subnet_name" {
  default = "vnet2-subnet1"
}

# nicに付与するIPアドレス
variable "IPAddress" {
  default = "172.168.160.27"
}

# 仮想マシンのサイズ
variable "vmsize" {
  default = "Standard_B2ms"
}

# ディスクタイプ
variable "managed_disk_type" {
  default = "StandardSSD_LRS"
}

