terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

#### データリソースの設定
data "azurerm_resource_group" "main" {
  name = local.resource_group_name
}

data "azurerm_subnet" "main" {
  name                 = local.subnet_name
  virtual_network_name = local.vnet_name
  resource_group_name  = local.vnet_resource_group_name
}

data "azurerm_image" "image" {
  name                = "terraformtest-imagev1"
  resource_group_name = "terraform-test"
}

#### VMの設定

## NICの作成
resource "azurerm_network_interface" "windows_nic" {
  name                = "${local.hostname}-nic1"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.main.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.IPAddress
  }

  tags = {
    server = "${local.hostname}"
  }
}

## VMの作成
resource "azurerm_virtual_machine" "windows" {
  name                  = local.hostname
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  vm_size                  = local.vmsize
  network_interface_ids = [azurerm_network_interface.windows_nic.id]
  delete_os_disk_on_termination = true
  tags = {
    server = "${local.hostname}"
  }

  os_profile {
    computer_name  = local.hostname
    admin_username = "localadmin"
    admin_password = "${local.hostname}abc"
  }
  os_profile_windows_config {
    enable_automatic_upgrades = false
    provision_vm_agent        = false
  }
  storage_image_reference {
    id = data.azurerm_image.image.id
  }
  storage_os_disk {
    name              = "${local.hostname}-osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = local.managed_disk_type
  }
}


#### 変数の宣言

## ほぼ固定

locals{
 vnet_name = "vnet2"
 vnet_resource_group_name = "PoC-virtualwanrg"
}


## サーバ毎

# サーバ名
locals {
 hostname = "terratest-001"
}

# サーバと関連リソースが属するリソースグループ
locals {
 resource_group_name = "terraform-test1"
}

# サーバを接続するサブネット
locals {
 subnet_name = "vnet2-subnet1"
}

# nicに付与するIPアドレス
locals {
 IPAddress = "172.168.160.25"
}

# 仮想マシンのサイズ
locals {
 vmsize = "Standard_B2s"
}

# ディスクタイプ
locals {
 managed_disk_type = "StandardSSD_LRS"
}
