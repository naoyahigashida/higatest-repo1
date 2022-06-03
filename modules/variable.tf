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

## サーバ毎

# サーバ名
variable "hostname" {
}
# サーバと関連リソースが属するリソースグループ
variable "resource_group_name" {
}
# サーバを接続するサブネット
variable "subnet_name" {
}
# 管理者ユーザ（そのままで良ければ変更不要）
variable "admin_username" {
  default = "localadmin"
}
# nicに付与するIPアドレス
variable "IPAddress" {
}
# DNS
variable "dns_servers" {
  default = ["172.168.160.1","172.168.160.2"]
}
# 仮想マシンのサイズ
variable "vmsize" {
}
# ディスクタイプ
# 開発・検証・PoC
variable "managed_disk_type" {
  default = "StandardSSD_LRS"
}

# 本番
#variable "managed_disk_type" {
#  default = "Premium_LRS"
#}
