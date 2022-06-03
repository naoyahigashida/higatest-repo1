module "terratest-004" {
  source = "./modules"
  hostname = "terratest-004"
  resource_group_name = "terraform-test"
  subnet_name = "vnet2-subnet1"
  IPAddress = "172.168.160.28"
  vmsize = "Standard_B2ms"
  managed_disk_type = "StandardSSD_LRS"
}
