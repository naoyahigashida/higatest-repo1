## ほぼ固定
variable "location" {
  default = "japaneast"
}
variable "vnet_name" {
  default = "vnet2"
}
variable "vnet_resource_group_name" {
  default = "PoC-virtualwanrg"
}

variable "hostname" {
}

variable "resource_group_name" {
}

variable "subnet_name" {
}

variable "admin_username" {
  default = "localadmin"
}

variable "IPAddress" {
}

variable "vmsize" {
}

## 開発・検証・PoC
variable "managed_disk_type" {
  default = "StandardSSD_LRS"
}

## 本番
##variable "managed_disk_type" {
##  default = "Premium_LRS"
##}
