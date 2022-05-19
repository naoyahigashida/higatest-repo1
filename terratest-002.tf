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
data "azurerm_resource_group" "main2" {
  name = local.terratest-002_resource_group_name
}

data "azurerm_subnet" "main2" {
  name                 = local.terratest-002_subnet_name
  virtual_network_name = local.terratest-002_vnet_name
  resource_group_name  = local.terratest-002_vnet_resource_group_name
}

data "azurerm_image" "image2" {
  name                = "terraformtest-imagev1"
  resource_group_name = "terraform-test"
}

#### VMの設定

## NICの作成
resource "azurerm_network_interface" "windows_nic2" {
  name                = "${local.terratest-002_hostname}-nic1"
  location            = data.azurerm_resource_group.main2.location
  resource_group_name = data.azurerm_resource_group.main2.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.main2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.terratest-002_IPAddress
  }

  tags = {
    server = "${local.terratest-002_hostname}"
  }
}

## VMの作成
resource "azurerm_virtual_machine" "windows2" {
  name                  = local.terratest-002_hostname
  location              = data.azurerm_resource_group.main2.location
  resource_group_name   = data.azurerm_resource_group.main2.name
  vm_size                  = local.terratest-002_vmsize
  network_interface_ids = [azurerm_network_interface.windows_nic2.id]
  delete_os_disk_on_termination = true
  tags = {
    server = "${local.terratest-002_hostname}"
  }

  os_profile {
    computer_name  = local.terratest-002_hostname
    admin_username = "localadmin"
    admin_password = "${local.terratest-002_hostname}abc"
  }
  os_profile_windows_config {
    enable_automatic_upgrades = false
    provision_vm_agent        = false
  }
  storage_image_reference {
    id = data.azurerm_image.image2.id
  }
  storage_os_disk {
    name              = "${local.terratest-002_hostname}-osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = local.terratest-002_managed_disk_type
  }
}

#### 変数の宣言

## ほぼ固定

locals{
 terratest-002_vnet_name = "vnet2"
 terratest-002_vnet_resource_group_name = "PoC-virtualwanrg"
}


## サーバ毎

# サーバ名
locals {
 terratest-002_hostname = "terratest-002"
}

# サーバと関連リソースが属するリソースグループ
locals {
 terratest-002_resource_group_name = "terraform-test2"
}

# サーバを接続するサブネット
locals {
 terratest-002_subnet_name = "vnet2-subnet1"
}

# nicに付与するIPアドレス
locals {
 terratest-002_IPAddress = "172.168.160.27"
}

# 仮想マシンのサイズ
locals {
 terratest-002_vmsize = "Standard_B2ms"
}

# ディスクタイプ
locals {
 terratest-002_managed_disk_type = "StandardSSD_LRS"
}
