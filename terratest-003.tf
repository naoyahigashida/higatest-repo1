module "terratest-003" {
  source = "./modules"
  hostname = "terratest-003"
  resource_group_name = "terraform-test2"
  subnet_name = "vnet2-subnet1"
  IPAddress = "172.168.160.27"
  vmsize = "Standard_B2ms"
  managed_disk_type = "StandardSSD_LRS"
}